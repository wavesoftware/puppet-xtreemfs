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
  end

  describe 'getting instances' do
    it { expect(provider.class.instances).to be_empty }
  end

  describe 'loading provider data for file' do
    before :each do
      expect(File).to receive(:file?).and_return(true)
    end
    context 'on xtreemfs mounted volume' do
      context 'with file that is not replicated' do
        before :each do
          expect(provider.class).to receive(:xtfsutil).
            with('/mnt/xtfs/file1').once.and_return(xtfsutil_output_not_repl)
        end
        it { expect(provider.class.load_provider('/mnt/xtfs/file1')).not_to be_nil }
        it { expect(provider.class.load_provider('/mnt/xtfs/file1').policy).to eq 'none' }
        it { expect(provider.class.load_provider('/mnt/xtfs/file1').factor).to eq 1 }
      end
      context 'with file that is replicated with WqRw, factor 2' do
        before :each do
          expect(provider.class).to receive(:xtfsutil).
            with('/mnt/xtfs/file1').once.and_return(xtfsutil_output_wqrq_2_repl)
        end
        it { expect(provider.class.load_provider('/mnt/xtfs/file1')).not_to be_nil }
        it { expect(provider.class.load_provider('/mnt/xtfs/file1').policy).to eq 'WqRq' }
        it { expect(provider.class.load_provider('/mnt/xtfs/file1').factor).to eq 2 }
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
end