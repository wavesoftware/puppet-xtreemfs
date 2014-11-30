module Puppet_X
module Wavesoftware
module Xtreemfs
module Type

  # Common abstract type for replicable resources that is policy and replicate
  class Replicable

    # Configure a type
    #
    # @param type [Puppet::Type::Xtreemfs_replicate,Puppet::Type::Xtreemfs_policy] a child type 
    # @return [block] a configured block
    def self.configure type

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
          value.to_s
        end
      end

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

      type.validate do
        factor = self[:factor].to_s.to_i
        if self[:policy].to_sym == :none and factor > 1
          fail "If replication policy is set to `none`, you can't set replication factor to value greater then 1"
        end
      end
    end

  end

end
end
end
end