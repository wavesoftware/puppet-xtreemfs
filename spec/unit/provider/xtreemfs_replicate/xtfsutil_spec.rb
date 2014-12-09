require 'spec_helper'

describe Puppet::Type.type(:xtreemfs_replicate).provider(:xtfsutil) do

  let(:xtfsutil_output_invalid) do
    <<-eos
    xtfsutil failed: Path doesn't point to an entity on an XtreemFS volume!
    xattr xtreemfs.url is missing.
    eos
  end

  let(:xtfsutil_output_directory) do
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

  let(:xtfsutil_output_not_repl) do
    <<-eos
    Path (on volume)     /file1
    XtreemFS file Id     bf637412-6298-43b6-9929-43554662b9b4:5
    XtreemFS URL         pbrpc://master.vagrant.dev:32638/myVolume/file1
    Owner                root
    Group                root
    Type                 file
    Replication policy   none (not replicated)
    XLoc version         0
    Replicas:
      Replica 1
         Striping policy     STRIPING_POLICY_RAID0 / 1 / 128kB
         OSD 1               ba5b8462-13e2-4fee-bc08-f2ccfa0ac2e3 (172.28.128.3:32640)
    eos
  end

  let(:xtfsutil_output_wqrq_2_repl) do
    <<-eos
    Path (on volume)     /file1
    XtreemFS file Id     bf637412-6298-43b6-9929-43554662b9b4:5
    XtreemFS URL         pbrpc://master.vagrant.dev:32638/myVolume/file1
    Owner                root
    Group                root
    Type                 file
    Replication policy   WqRq
    XLoc version         2
    Replicas:
      Replica 1
         Striping policy     STRIPING_POLICY_RAID0 / 1 / 128kB
         OSD 1               ba5b8462-13e2-4fee-bc08-f2ccfa0ac2e3 (172.28.128.3:32640)
      Replica 2
         Striping policy     STRIPING_POLICY_RAID0 / 1 / 128kB
         OSD 2               b99108ec-43fd-4f45-a35e-8e88547815d8 (172.28.128.4:32640)
    eos
  end

  let(:xtfsutil_output_list_osds) do
    <<-eos
    OSDs suitable for new replicas: 
      f139a615-e31e-4543-ae83-8523394e93cb (172.28.128.5:32640)
      1df11915-e0b3-495f-b157-5e609062521b (172.28.128.6:32640)
    eos
  end

  let(:sample_repl) do
    {
      :file     => '/mnt/xtfs/file1',
      :policy   => :WqRq,
      :factor   => 2,
    }
  end

  let(:resource) do
    raw = sample_repl.dup
    raw[:provider] = described_class.name
    Puppet::Type.type(:xtreemfs_replicate).new(raw)
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

  describe 'loading provider data for file' do

    subject { provider.class.load_provider('/mnt/xtfs/file1') } 

    context 'on non existing file' do
      before :each do
        expect(File).to receive(:file?).and_return(false)
      end
      it { should be_nil }
    end

    context 'on existing file' do

      before :each do
        expect(File).to receive(:file?).and_return(true)
      end

      context 'on xtreemfs mounted volume' do

        context 'with file that is not replicated' do
          before :each do
            expect(provider.class).to receive(:xtfsutil).
              with('/mnt/xtfs/file1').once.and_return(xtfsutil_output_not_repl)
          end
          
          it { should_not be_nil }
          its('policy') { should eq :none }
          its('factor') { should eq 1 }
        end

        context 'with file that is replicated with WqRw, factor 2' do
          before :each do
            expect(provider.class).to receive(:xtfsutil).
              with('/mnt/xtfs/file1').once.and_return(xtfsutil_output_wqrq_2_repl)
          end
          
          it { should_not be_nil }
          its('policy') { should eq :WqRq }
          its('factor') { should eq 2 }
        end

      end

      context 'outside of xtreemfs volume' do
        before :each do
          expect(provider.class).to receive(:xtfsutil).
            with('/mnt/xtfs/file1').once.and_return(xtfsutil_output_invalid)
        end

        it do
          expect { subject }.to raise_error(/Tring to replicate file, that is not on XtreemFS volume/)
        end
      end

    end

  end

  describe 'prefetching resources' do
    before :each do
      expect(File).to receive(:file?).and_return(true)
      expect(provider.class).to receive(:xtfsutil).
            with('/mnt/xtfs/file1').once.and_return(xtfsutil_output_wqrq_2_repl)
    end
    it do
      resources = {'/mnt/xtfs/file1' => resource}
      expect(provider.class.prefetch resources).not_to be_nil
    end
  end

  describe 'validating a resource' do

    subject { provider.validate }

    context 'on non existing file' do
      before { expect(File).to receive(:exists?).and_return(false) }
      it { expect{ subject }.to raise_error(Puppet::Error, /A file for replicate must exists/) }
    end
    context 'on existing file' do
      before { expect(File).to receive(:exists?).and_return(true) }
      context 'being an regular file' do
        before { expect(File).to receive(:file?).and_return(true) }
        it { expect{ subject }.not_to raise_error }
      end
      context 'being an non regular file for ex.: directory' do
        before do
          expect(File).to receive(:file?).and_return(false)
          root_stat = File.stat '/'
          expect(File).to receive(:stat).and_return(root_stat)
        end
        it do
          expect{ subject }.
            to raise_error(Puppet::Error, /A file for replicate must be regular file, but directory given/)
        end
      end
    end

  end

  context 'within valid validation context' do

    before :each do 
      expect(File).to receive(:exists?).at_least(:once).and_return(true)
      expect(File).to receive(:file?).at_least(:once).and_return(true)
      allow(provider.class).to receive(:xtfsutil).
        with('/mnt/xtfs/file1').once.and_return(xtfsutil_output_wqrq_2_repl)
    end

    describe 'flushing a resource without prefeched resource and properties are not being set' do
      it { expect{ provider.flush }.not_to raise_error }
    end

    context 'within fully prefetched provider' do
    
      before :each do
        resources = {'/mnt/xtfs/file1' => resource}
        provider.class.prefetch resources
        loaded = resources['/mnt/xtfs/file1'].provider
        phash = loaded.instance_variable_get('@property_hash')
        rawprops = loaded.instance_variable_get('@rawprops')
        provider.instance_variable_set '@property_hash', phash
        provider.instance_variable_set '@rawprops', rawprops
      end

      describe 'flushing previously set policy property' do

        subject { provider.flush_policy }

        before :each do 
          provider.policy = :none
          expect(provider.class).to receive(:xtfsutil) do |arg|
            expect(arg.size).to eq(3)
            expect(arg[0]).to eq("--delete-replica")
            expect(arg[1]).to match(/b99108ec-43fd-4f45-a35e-8e88547815d8|ba5b8462-13e2-4fee-bc08-f2ccfa0ac2e3/)
            expect(arg[2]).to eq("/mnt/xtfs/file1")
          end
          expect(provider.class).to receive(:xtfsutil).
            with(['--set-replication-policy', :none, '/mnt/xtfs/file1']).
            and_return('')
        end
        it 'should not raise Exception' do
          expect { subject }.not_to raise_error
        end
      end

      describe 'flushing previously set factor property' do
        subject { provider.flush_factor }

        before :each do 
          expect(provider.class).to receive(:xtfsutil).
            with(['--list-osds', '/mnt/xtfs/file1']).
            and_return(xtfsutil_output_list_osds)
        end

        context 'when factor property has been set to value lower then aviailable OSDs servers' do
          before :each do
            provider.factor = 3
            expect(provider.class).to receive(:xtfsutil).
              with(["--add-replica", "auto", "/mnt/xtfs/file1"]).
              and_return('')
          end
          it 'should not raise Exception' do
            expect { subject }.not_to raise_error
          end
        end

        context 'when factor property has been set to value greater then aviailable OSDs servers' do
          before :each do
            provider.factor = 5
            expect(provider.class).to receive(:xtfsutil).
              with(["--add-replica", "auto", "/mnt/xtfs/file1"]).twice
            warn = 'There is not enough available OSD servers to adjust replication' + 
              ' factor to: 5. Setting replication factor to highest possible value: 4'
            expect(Puppet).to receive(:warning).with(warn)
          end
          it 'should not raise Exception' do
            expect { subject }.not_to raise_error
          end
        end

        context 'when factor property has been set to value lower than before' do
          before :each do
            provider.factor = 1
          end
          it 'should not raise Exception' do
            expect { subject }.not_to raise_error
          end
        end

      end

    end

  end
end