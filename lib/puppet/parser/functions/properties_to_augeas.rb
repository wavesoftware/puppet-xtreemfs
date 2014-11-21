module Puppet::Parser::Functions
  newfunction(:properties_to_augeas, :type => :rvalue, :doc => <<-EOS
    PRIVATE INTERNAL FUNCTION. Merges a given properties hash, with augeas 
    changes that must be applied in given configuration processor. 
    Returns in form aplicable by augeas.
    EOS
  ) do |args|

    raise(Puppet::ParseError, "properies_to_augeas(): Wrong number of arguments " +
      "given (#{args.size} for 1..2)") if args.size != 1 and args.size != 2

    extra_hash = args[0]
    augeas_changes = if args.size == 2 then args[1] else [] end

    unless extra_hash.respond_to?(:map) and augeas_changes.is_a?(Array) then
      message = "properies_to_augeas(): Wrong type of arguments given (#{extra_hash.class} for Hash, #{augeas_changes.class} for Array)"
      raise Puppet::ParseError, message
    end

    extra_list = extra_hash.map { |k, v| "set #{k} #{v}" }
    retval = extra_list.concat augeas_changes
    retval
  end
end