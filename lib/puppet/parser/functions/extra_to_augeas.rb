module Puppet::Parser::Functions
  newfunction(:extra_to_augeas, :type => :rvalue, :doc => <<-EOS
    PRIVATE INTERNALFUNCTION. Merges a given hash with extra parameters, with 
    changes that must be applied in given configuration processor.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "extra_to_augeas(): Wrong number of arguments " +
      "given (#{args.size} for 2)") if args.size != 2

    extra_hash     = args[0]
    augeas_changes = args[1]

    unless extra_hash.is_a?(Hash) && augeas_changes.is_a?(Array)
      raise(Puppet::ParseError, "extra_to_augeas(): Wrong type of arguments given (#{extra_hash.class} for Hash, #{augeas_changes.class} for Array)") 
    end

    extra_list = extra_hash.map { |k, v| "set #{k} #{v}" }
    retval = extra_list.concat augeas_changes
    retval
  end
end