require 'spec_helper'

describe Puppet::Type.type(:xtreemfs_replicate) do
  before do
    @provider_class = described_class.provide(:simple) { mk_resource_methods }
    @provider_class.stub(:suitable?).and_return true
    described_class.stub(:defaultprovider).and_return @provider_class
  end

  describe "namevar validation" do
    it "should have :file as its namevar" do
      expect(described_class.key_attributes).to eq([:file])
    end
    it "should allow alphanumeric in names" do
      expect { described_class.new(:file => 'foobar') }.not_to raise_error
    end
  end

  describe "when validating attributes" do
    [:file].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:policy, :factor].each do |property|
      it "should have a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end
  end

  describe "when validating values" do
    describe "policy" do
      it "should support WqRq as a value for policy" do
        expect { described_class.new(:policy => 'WqRq', :file => '/file1') }.to_not raise_error
      end
      it "should support all as a value for policy" do
        expect { described_class.new(:policy => 'all', :file => '/mnt/file1') }.to_not raise_error
      end
      it "should support none as a value for policy" do
        expect { described_class.new(:policy => 'none', :file => '/mnt/file2') }.to_not raise_error
      end
      it "should support readonly as a value for policy" do
        expect { described_class.new(:policy => 'readonly', :file => '/mnt/file3') }.to_not raise_error
      end
      it "should not support other values" do
        expect { described_class.new(:policy => 'none s', :file => '/mnt/file2') }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end
    describe 'factor' do
      it "should support 1 as a value for factor" do
        expect { described_class.new(:file => 'foo', :factor => 1) }.not_to raise_error
      end
      it "should support 15 as a value for factor" do
        expect { described_class.new(:file => 'foo', :policy => :WqRq, :factor => 15) }.not_to raise_error
      end
      it "should not support 0 as a value for factor" do
        expect { described_class.new(:file => 'foo', :factor => 0) }.
          to raise_error(Puppet::Error, /Replication factor must be integer value/)
      end
      it "should not support -3 as a value for factor" do
        expect { described_class.new(:file => 'foo', :factor => -3) }.
          to raise_error(Puppet::Error, /Replication factor must be integer value/)
      end
      it "should not support sdfsd as a value for factor" do
        expect { described_class.new(:file => 'foo', :factor => 'sdfsd') }.
          to raise_error(Puppet::Error, /Replication factor must be integer value/)
      end
      it "should not support true as a value for factor" do
        expect { described_class.new(:file => 'foo', :factor => true) }.
          to raise_error(Puppet::Error, /Replication factor must be integer value/)
      end
      it "should not support 5.66 as a value for factor" do
        expect { described_class.new(:file => 'foo', :policy => :all, :factor => 5.66) }.
          to raise_error(Puppet::Error, /Replication factor must be integer value/)
      end
    end
    describe 'policy and factor' do
      it "should not support values greater than 1 as a value for factor, when policy is set to none" do
        expect { described_class.new(:file => 'foo', :policy => 'none', :factor => 15) }.
          to raise_error(Puppet::Error, /If replication policy is set to `none`, you can't set replication factor to value greater then 1/)
      end
    end
  end
end
