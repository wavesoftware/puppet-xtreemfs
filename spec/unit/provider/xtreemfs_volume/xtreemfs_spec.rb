require 'spec_helper'

describe Puppet::Type.type(:xtreemfs_volume).provider(:xtreemfs) do

  let(:lsfs_empty_valid_output) do
    <<-eos
    Listing all volumes of the MRC: slave4.vm
    Volumes on slave4.vm:32636 (Format: volume name -> volume UUID):
    End of List.
    eos
  end

  let(:lsfs_valid_output_with_1_vol) do
    <<-eos
    Listing all volumes of the MRC: slave4.vm
    Volumes on slave4.vm:32636 (Format: volume name -> volume UUID):
      myVolume  ->  df28f334-df35-40cc-9f1a-9996a3eead1c
    End of List.
    eos
  end

  let(:lsfs_valid_output_with_2_vol) do
    <<-eos
    Listing all volumes of the MRC: slave4.vm
    Volumes on slave4.vm:32636 (Format: volume name -> volume UUID):
      myVolume  ->  df28f334-df35-40cc-9f1a-9996a3eead1c
      secondVol  ->  3972cc46-9cfd-4395-8d48-2154337e4c89
    End of List.
    eos
  end

  let(:rawvalues) do
    {
      :first => {
        :uuid   => 'df28f334-df35-40cc-9f1a-9996a3eead1c',
        :ensure => :present,
        :name   => 'myVolume'
      },
      :second => {
        :uuid   => '3972cc46-9cfd-4395-8d48-2154337e4c89',
        :ensure => :present,
        :name   => 'secondVol'
      }
    }
  end

  let(:sample_vol) do
    {
      :name     => 'myVolume',
      :ensure   => :present,
      :host     => 'slave4.vm',
    }
  end

  let(:resource) do
    raw = sample_vol.dup
    raw[:provider] = described_class.name
    Puppet::Type.type(:xtreemfs_volume).new(raw)
  end

  let(:provider) do
    resource.provider
  end

  before :each do
    allow(provider.class).to receive(:suitable?).and_return(true)
    allow(Puppet::Util).to receive(:which).with('mkfs.xtreemfs').and_return('/usr/sbin/mkfs.xtreemfs')
    allow(Puppet::Util).to receive(:which).with('lsfs.xtreemfs').and_return('/usr/sbin/lsfs.xtreemfs')
    allow(Puppet::Util).to receive(:which).with('rmfs.xtreemfs').and_return('/usr/sbin/rmfs.xtreemfs')
    allow(provider.class).to receive(:is_port_open?).with('slave4.vm', 32636).and_return(true)
    allow(provider.class).to receive(:lsfs_xtreemfs) { |arg|
      arg = [arg] unless arg.is_a? Array
      arg = arg.pop
      if arg == 'slave4.vm'
        lsfs_valid_output_with_2_vol
      else
        lsfs_empty_valid_output
      end
    }
    allow(Facter).to receive(:value).with(:fqdn).and_return('slave4.vm')
  end

  describe 'dashize' do
    context 'on deprecated dashed option: "--pem-certificate-file-path"' do
      subject { '--pem-certificate-file-path' }
      message = "Passing options with dashes are deprecated. Pass only opt name. You have given: '--pem-certificate-file-path'"
      before { expect(Puppet).to receive(:warning).with(message) }
      it { provider.dashize(subject).should eq('--pem-certificate-file-path') }
    end
    context 'on short option: "d"' do
      subject { 'd' }
      before { expect(Puppet).not_to receive(:warning) }
      it { provider.dashize(subject).should eq('-d') }
    end
    context 'on long option: "pem-certificate-file-path"' do
      subject { 'pem-certificate-file-path' }
      before { expect(Puppet).not_to receive(:warning) }
      it { provider.dashize(subject).should eq('--pem-certificate-file-path') }
    end
  end

  describe 'getting instances' do
    it { expect(provider.class.instances).not_to be_empty }
  end

  describe 'parsing an lsfs.xtreemfs output' do
    context 'with empty output' do
      let (:output) { '' }
      it { expect(provider.class.parse output).to be_empty }
    end
    context 'with "invalid" output' do
      let (:output) { 'invalid' }
      it { expect(provider.class.parse output).to be_empty }
    end
    context 'with "inv\nal\nid\n\n!!!" output' do
      let (:output) { "inv\nal\nid\n\n!!!" }
      it { expect(provider.class.parse output).to be_empty }
    end
    context 'with valid output, but with no volumes' do
      it { expect(provider.class.parse lsfs_empty_valid_output).to be_empty }
    end
    context 'with valid output, with one volume' do
      it { expect(provider.class.parse lsfs_valid_output_with_1_vol).not_to be_empty }
      it 'should contain "myVolume" with UUID' do
        expect(provider.class.parse lsfs_valid_output_with_1_vol).to eq([rawvalues[:first]])
      end
    end
    context 'with valid output, with two volumes' do
      it { expect(provider.class.parse lsfs_valid_output_with_2_vol).not_to be_empty }
      it 'should contain "myVolume" and "secondVol" with UUIDs' do
        expect(provider.class.parse lsfs_valid_output_with_2_vol).
          to eq([rawvalues[:first], rawvalues[:second]])
      end
    end
  end

  describe 'prefetching rawinstances' do
    context 'executing `lsfs_xtreemfs slave4.vm`' do
      it { expect(provider.class.lsfs_xtreemfs('slave4.vm')).not_to be_empty }
    end
    it { expect(provider.class.rawinstances).not_to be_empty }
    it 'should contain "myVolume" and "secondVol" with UUIDs' do
      expect(provider.class.rawinstances).to eq([rawvalues[:first], rawvalues[:second]])
    end
  end

  describe 'calculating commandline options' do
    context 'for lsfs_xtreemfs command' do
      context 'with invalid option: --non-existing-opt' do
        before { resource[:options] = { '--non-existing-opt' => 45 } }
        it { expect(provider.options :lsfs).to be_empty }
      end
      context 'with option for rmfs: --globus-gridmap' do
        before { resource[:options] = { '--globus-gridmap' => :undef } }
        it { expect(provider.options :lsfs).to be_empty }
      end
      context 'with one valid lsfs option (with deprecated hypens)' do
        before do
          resource[:options] = { 
            '--pem-certificate-file-path' =>  '/etc/ssl/certs/slave4.vm.crt'
          }
        end
        it { expect(provider.options :lsfs).not_to be_empty }
        it { expect(provider.options :lsfs).to eq(['--pem-certificate-file-path', '/etc/ssl/certs/slave4.vm.crt']) }
      end
      context 'with one valid lsfs option' do
        before do
          resource[:options] = { 
            'pem-certificate-file-path' =>  '/etc/ssl/certs/slave4.vm.crt'
          }
        end
        it { expect(provider.options :lsfs).not_to be_empty }
        it { expect(provider.options :lsfs).to eq(['--pem-certificate-file-path', '/etc/ssl/certs/slave4.vm.crt']) }
      end
      context 'with two valid lsfs options' do
        before do
          resource[:options] = { 
            'pem-certificate-file-path' => '/etc/ssl/certs/slave4.vm.crt',
            'pem-private-key-file-path' => '/etc/ssl/private/slave4.vm.pem'
          }
        end
        it { expect(provider.options :lsfs).not_to be_empty }
        it do
          expect(provider.options :lsfs).to eq([
            '--pem-certificate-file-path', '/etc/ssl/certs/slave4.vm.crt',
            '--pem-private-key-file-path', '/etc/ssl/private/slave4.vm.pem'
          ])
        end
      end
    end
    context 'for rmfs_xtreemfs command' do
      context 'with invalid option: non-existing-opt' do
        before { resource[:options] = { 'non-existing-opt' => 45 } }
        it { expect(provider.options :rmfs).to be_empty }
      end
      context 'with option for rmfs: globus-gridmap' do
        before { resource[:options] = { 'globus-gridmap' => nil } }
        it { expect(provider.options :rmfs).to eq(['--globus-gridmap']) }
      end
      context 'with valid lsfs and rmfs options and non existent one' do
        before do
          resource[:options] = { 
            'pem-certificate-file-path' => '/etc/ssl/certs/slave4.vm.crt',
            'unicore-gridmap'           => nil,
            'jennifer-connelly'         => 'naked'
          }
        end
        it { expect(provider.options :rmfs).not_to be_empty }
        it do
          expect(provider.options :rmfs).to eq([
            '--pem-certificate-file-path', '/etc/ssl/certs/slave4.vm.crt',
            '--unicore-gridmap'
          ])
        end
      end
    end
    context 'for mkfs_xtreemfs command with valid lsfs and rmfs options and non existent one' do
      before do
        resource[:options] = { 
          'pem-certificate-file-path' => '/etc/ssl/certs/slave4.vm.crt',
          'unicore-gridmap'           => nil,
          'jennifer-connelly'         => 'dressed'
        }
      end
      it { expect(provider.options :mkfs).not_to be_empty }
      it 'should passthru all options, without filtering' do
        expect(provider.options :mkfs).to eq([
          '--jennifer-connelly', 'dressed',
          '--pem-certificate-file-path', '/etc/ssl/certs/slave4.vm.crt',
          '--unicore-gridmap'
        ])
      end
    end

    context 'for mkfs_xtreemfs command with valid options and mkfs without value' do
      before do
        resource[:options] = { 
          'pem-certificate-file-path' => '/etc/ssl/certs/slave4.vm.crt',
          'chown-non-root'            => :undef
        }
      end
      it { expect(provider.options :mkfs).not_to be_empty }
      it 'should passthru all options, without filtering' do
        expect(provider.options :mkfs).to eq([
          '--chown-non-root',
          '--pem-certificate-file-path',
          '/etc/ssl/certs/slave4.vm.crt'
        ])
      end
    end
  end

  describe 'checking if exists?' do
    context 'without prefetched @property_hash' do
      before do
        expect(provider).to receive(:lsfs).once.and_call_original
      end
      it { expect(provider.exists?).to be_truthy }
    end
    context 'with @property_hash filled' do
      before :each do
        expect(provider.class).to receive(:load_provider).once.and_call_original
        resources = {'myVolume' => resource}
        provider.class.prefetch resources
      end
      it { expect(provider.exists?).to be_truthy }
      it { expect(provider.uuid).to eq('df28f334-df35-40cc-9f1a-9996a3eead1c') }
    end
  end

  describe 'creating a new volume' do
    before :each do
      expect(provider.class).to receive(:mkfs_xtreemfs).and_return('')
    end
    it do
      created = provider.create
      phash = created.provider.instance_variable_get('@property_hash')
      expect(created).not_to be_nil
      expect(phash).to include(:uuid => 'df28f334-df35-40cc-9f1a-9996a3eead1c')
    end
  end

  describe 'deleting existing volume' do
    before :each do
      expect(provider.class).to receive(:rmfs_xtreemfs).and_return('')
    end
    it do
      destroyed = provider.destroy
      phash = destroyed.provider.instance_variable_get('@property_hash')
      expect(destroyed).not_to be_nil
      expect(phash).not_to include(:uuid => 'df28f334-df35-40cc-9f1a-9996a3eead1c')
    end
  end

  describe 'checking is ports are open' do

    let(:params) do
      {}
    end

    before :each do
      expect(provider.class).to receive(:is_port_open?).and_call_original
      require 'socket'
      params[:serv] = TCPServer.new('localhost', 49746)
    end
    after :each do
      params[:serv].shutdown
    end
    context 'when checking for 49746 on localhost' do
      it { expect(provider.class.is_port_open? 'localhost', 49746).to be_truthy }
    end
    context 'when checking for 49747 on localhost' do
      it { expect(provider.class.is_port_open? 'localhost', 49747).to be_falsey }
    end
    context 'when checking for 41416 on wavesoftware.pl' do
      it { expect(provider.class.is_port_open? 'wavesoftware.pl', 41416).to be_falsey }
    end
  end
end