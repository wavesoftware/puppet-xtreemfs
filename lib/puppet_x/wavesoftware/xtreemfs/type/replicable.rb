# A puppet x module
module Puppet_X
# A Wavesoftware puppet_x module
module Wavesoftware
# XtreemFS module
module Xtreemfs
# A XtreemFS type module that holds all custom types for XtreemFS
module Type

  # Common abstract type for replicable resources that is policy and replicate
  class Replicable

    # A child type
    # @return [Puppet::Type::Xtreemfs_replicate,Puppet::Type::Xtreemfs_policy] a child type
    attr_accessor :type

    # A constructor
    #
    # @param type [Puppet::Type::Xtreemfs_replicate,Puppet::Type::Xtreemfs_policy] a child type
    def initialize type
      @type = type
    end

    # Configure a policy property
    # @return [Puppet::Type::Xtreemfs_replicate,Puppet::Type::Xtreemfs_policy] a child type
    def configure_policy
      type.newproperty :policy do
        desc <<-eos
        The replication policy defines how a file is replicated. The policy
        can be changed for a file that has replicas, but puppet will remove
        all replicas before changing this property.
        eos

        defaultto :none
        newvalues :none, :ronly, :readonly, :WqRq, :quorum, :WaR1, :all

        munge do |value|
          value = value.to_sym
          if value == :readonly
            value = :ronly
          elsif value == :quorum
            value = :WqRq
          elsif value == :all
            value = :WaR1
          end
          value.to_sym
        end
      end
    end

    # Configure a factor property
    # @return [Puppet::Type::Xtreemfs_replicate,Puppet::Type::Xtreemfs_policy] a child type
    def configure_factor
      type.newproperty :factor do
        desc <<-eos
        The replication factor defines on how many nodes a file is replicated.
        eos

        defaultto 1

        validate do |value|
          factor = value.to_s.to_i
          unless (factor >= 1 and factor.to_s == value.to_s)
            fail "Replication factor must be integer value, that is greater or equal to 1"
          end
        end

        munge do |value|
          value.to_s.to_i
        end
      end
    end

    # Configure a global type validation
    # @return [Puppet::Type::Xtreemfs_replicate,Puppet::Type::Xtreemfs_policy] a child type
    def configure_global_validation
      type.validate do
        factor = self[:factor].to_s.to_i
        if self[:policy].to_sym == :none and factor > 1
          fail "If replication policy is set to `none`, you can't set replication factor to value greater then 1"
        end
      end
    end

    # Configure a type
    #
    # @param type [Puppet::Type::Xtreemfs_replicate,Puppet::Type::Xtreemfs_policy] a child type 
    # @return [Puppet::Type::Xtreemfs_replicate,Puppet::Type::Xtreemfs_policy] a child type
    def self.configure type
      repl = Replicable.new type
      repl.configure_policy
      repl.configure_factor
      repl.configure_global_validation
    end

  end

end
end
end
end