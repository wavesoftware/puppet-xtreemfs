require 'spec_helper'

describe Puppet::Type.type(:xtreemfs_policy) do
  before do
    @provider_class = described_class.provide(:simple) { mk_resource_methods }
    @provider_class.stub(:suitable?).and_return true
    described_class.stub(:defaultprovider).and_return @provider_class
  end

  describe "validating values of policy and factor" do
    context 'when values greater than 1 as a value for factor, when policy is set to none' do
      subject { described_class.new(:directory => 'foo', :policy => :none, :factor => 15) }
      it do
        expect { subject }.
          to raise_error(Puppet::Error, /If replication policy is set to `none`, you can't set replication factor to value greater then 1/)
      end
    end
    context 'when values less or equal 1 as a value for factor, when policy is set value other then none' do
      subject { described_class.new(:directory => 'foo', :policy => :quorum, :factor => 1) }
      it do
        expect { subject }.
          to raise_error(Puppet::Error, /If replication policy is other then `none`, you must set set replication factor to value greater then 1/)
      end
    end
  end

end