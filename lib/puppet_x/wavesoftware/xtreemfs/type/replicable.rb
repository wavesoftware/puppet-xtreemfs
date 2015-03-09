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

    class << self

      # Configure a policy property
      # @param type [Puppet::Type] a child type
      # @return [Puppet::Type] a child type
      def configure_policy(type)
  
        type.desc <<-eos
        The replication policy defines how a file is replicated. The policy
        can be changed for a file that has replicas, but puppet will remove
        all replicas before changing this property.
        eos
  
        type.defaultto :none
        type.newvalues :none, :ronly, :readonly, :WqRq, :quorum, :WaR1, :all
  
        type.munge do |value|
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
  
      # Configure a factor property
      # @param type [Puppet::Type] a child type
      # @return [Puppet::Type] a child type
      def configure_factor(type)
        type.desc <<-eos
        The replication factor defines on how many nodes a file is replicated.
        eos
  
        type.defaultto 1
  
        type.validate do |value|
          factor = value.to_s.to_i
          unless (factor >= 1 and factor.to_s == value.to_s)
            fail "Replication factor must be integer value, that is greater or equal to 1"
          end
        end
  
        type.munge do |value|
          value.to_s.to_i
        end
      end
  
      # Configure a global type validation
      # @param type [Puppet::Type] a child type
      # @return [Puppet::Type] a child type
      def configure_global_validation(type)
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
end