require 'spec_helper'

describe Puppet::Type.type(:xtreemfs_policy).provider(:xtfsutil) do

  let(:xtfsutil_output_invalid) do
    <<-eos
    xtfsutil failed: Path doesn't point to an entity on an XtreemFS volume!
    xattr xtreemfs.url is missing.
    eos
  end

  let(:xtfsutil_output_directory_none) do
    <<-eos
    Path (on volume)     /
    XtreemFS file Id     bf637412-6298-43b6-9929-43554662b9b4:1
    XtreemFS URL         pbrpc://master.vagrant.dev:32638/myVolume
    Owner                root
    Group                root
    Type                 volume
    Available/Used Space 17 GB / 12 bytes
    Num. Files/Dirs      1 / 1
    Access Control p.    POSIX (permissions & ACLs)
    OSD Selection p.     1000,3002
    Replica Selection p. default
    Default Striping p.  STRIPING_POLICY_RAID0 / 1 / 128kB
    Default Repl. p.     not set
    Snapshots enabled    no
    Selectable OSDs      ba5b8462-13e2-4fee-bc08-f2ccfa0ac2e3 (172.28.128.3:32640)
    eos
  end

  let(:xtfsutil_output_directory_ronly_2) do
    <<-eos
    Path (on volume)     /
    XtreemFS file Id     bf637412-6298-43b6-9929-43554662b9b4:1
    XtreemFS URL         pbrpc://master.vagrant.dev:32638/myVolume
    Owner                root
    Group                root
    Type                 volume
    Available/Used Space 17 GB / 12 bytes
    Num. Files/Dirs      1 / 1
    Access Control p.    POSIX (permissions & ACLs)
    OSD Selection p.     1000,3002
    Replica Selection p. default
    Default Striping p.  STRIPING_POLICY_RAID0 / 1 / 128kB
    Default Repl. p.     ronly with 2 replicas, partial replicas
    Snapshots enabled    no
    Selectable OSDs      ba5b8462-13e2-4fee-bc08-f2ccfa0ac2e3 (172.28.128.3:32640)
    eos
  end

  let(:sample_repl) do
    {
      :directory => '/mnt/xtfs/directory1',
      :policy    => :WqRq,
      :factor    => 2,
    }
  end

  let(:resource) do
    raw = sample_repl.dup
    raw[:provider] = described_class.name
    Puppet::Type.type(:xtreemfs_policy).new(raw)
  end

  let(:provider) do
    resource.provider
  end

  before :each do
    allow(provider.class).to receive(:suitable?).and_return(true)
    allow(provider.class).to receive(:which).with(:xtfsutil).and_return('/usr/bin/xtfsutil')
    allow(provider.class).to receive(:xtfsutil)
  end

  describe 'getting instances' do
    it { expect(provider.class.instances).to be_empty }
  end

  describe "parsing a default replication policy" do
    let(:method) { lambda { |str| provider.class.parse_drp(str) } }
    context 'when set to none' do
      it { method.call('not set').should eq({ :policy => :none, :factor => 1 }) }
    end
    context 'when set to ronly with 2 replicas' do
      it do
        method.call( 'ronly with 2 replicas, partial replicas' ).
          should eq({ :policy => :ronly, :factor => 2 })
      end
    end
    context 'when set to WaR1 with 3 replicas' do
      it do
        method.call( 'WaR1 with 3 replicas' ).
          should eq({ :policy => :WaR1, :factor => 3 })
      end
    end
    context 'when set to WqRq with 4 replicas' do
      it do
        method.call( 'WqRq with 4 replicas' ).
          should eq({ :policy => :WqRq, :factor => 4 })
      end
    end
  end

  describe 'loading provider data for directory' do

    subject { provider.class.load_provider('/mnt/xtfs/directory1') } 

    context 'on non existing directory' do
      before :each do
        expect(File).to receive(:directory?).and_return(false)
      end
      it { should be_nil }
    end

    context 'on existing directory' do

      before :each do
        expect(File).to receive(:directory?).and_return(true)
      end

      context 'on xtreemfs mounted volume' do

        context 'with directory that is not replicated' do
          before :each do
            expect(provider.class).to receive(:xtfsutil).
              with('/mnt/xtfs/directory1').once.and_return(xtfsutil_output_directory_none)
          end
          
          it { should_not be_nil }
          its('policy') { should eq :none }
          its('factor') { should eq 1 }
        end

        context 'with directory that is replicated with WqRw, factor 2' do
          before :each do
            expect(provider.class).to receive(:xtfsutil).
              with('/mnt/xtfs/directory1').once.and_return(xtfsutil_output_directory_ronly_2)
          end
          
          it { should_not be_nil }
          its('policy') { should eq :ronly }
          its('factor') { should eq 2 }
        end

      end

      context 'outside of xtreemfs volume' do
        before :each do
          expect(provider.class).to receive(:xtfsutil).
            with('/mnt/xtfs/directory1').once.and_return(xtfsutil_output_invalid)
        end

        it do
          expect { subject }.to raise_error(/Tring to replicate file, that is not on XtreemFS volume/)
        end
      end

    end
  end


  describe 'prefetching resources' do
    before :each do
      expect(File).to receive(:directory?).and_return(true)
      expect(provider.class).to receive(:xtfsutil).
            with('/mnt/xtfs/directory1').once.and_return(xtfsutil_output_directory_ronly_2)
    end
    it do
      resources = {'/mnt/xtfs/directory1' => resource}
      expect(provider.class.prefetch resources).not_to be_nil
    end
  end

  describe 'validating a resource' do

    subject { provider.validate }

    context 'tring to set policy with factor eq 1' do
      before :each do
        expect(provider).to receive(:resource).at_least(:once).
          and_return({ :directory => '/mnt/xtfs/dir1', :policy => :WqRq, :factor => 1 })
      end
      it { expect{ subject }.to raise_error(Puppet::Error, /A replication factor must be greater then 1/) }
    end
    context 'on non existing file' do
      before { expect(File).to receive(:exists?).and_return(false) }
      it { expect{ subject }.to raise_error(Puppet::Error, /A directory for policy must exists/) }
    end
    context 'on existing file' do
      before { expect(File).to receive(:exists?).and_return(true) }
      context 'being an regular directory' do
        before { expect(File).to receive(:directory?).and_return(true) }
        it { expect{ subject }.not_to raise_error }
      end
      context 'being an non regular directory for ex.: file' do
        before do
          expect(File).to receive(:directory?).and_return(false)
          root_stat = File.stat __FILE__
          expect(File).to receive(:stat).and_return(root_stat)
        end
        it do
          expect{ subject }.
            to raise_error(Puppet::Error, /A directory for policy must be a directory, but file given/)
        end
      end
    end

  end

  describe 'flush all at once' do
    before :each do
      expect(provider.class).to receive(:xtfsutil).with([
        "--set-drp", 
        "--replication-policy", :WqRq, 
        "--replication-factor", 2, 
        "/mnt/xtfs/directory1"
      ]).and_return('Updated default replication policy to: READONLY with 2 replicas')
    end
    it { provider.flush_all.should_not be_nil }
    it { provider.flush_all.should match(/Updated.+READONLY with 2 replicas/) }
  end

end