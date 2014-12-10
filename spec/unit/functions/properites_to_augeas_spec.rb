require 'spec_helper'

describe 'properties_to_augeas', :type => :puppet_function do
  it 'should return correct 4 element array after joining 2 element hash with 2 incoming augeas changes' do
    properties = { 
      'setting_one.to' => 5,
      :something       => 'http://afsdfsd:222/'
    }
    augeas_chages = [
      'set dir_service.host http://localhost:30638',
      'set object_dir /var/lib/xtreemfs/objs'
    ]
    output = [
      "set dir_service.host http://localhost:30638",
      "set object_dir /var/lib/xtreemfs/objs",
      "set setting_one.to 5",
      "set something http://afsdfsd:222/"
    ]
    should run.with_params(properties, augeas_chages).and_return(output)
  end
  it 'should throw Puppet::ParseError if passing 0 args' do
    should run.
      with_params().and_raise_error(
        Puppet::ParseError, 
        'properies_to_augeas(): Wrong number of arguments given (0 for 1..2)'
      )
  end
  it 'should throw Puppet::ParseError if passing 1 arg' do
    should run.
      with_params({}).and_return([])
  end
  it 'should throw Puppet::ParseError if passing 3 and more args' do
    should run.
      with_params(1, 2, 3).and_raise_error(
        Puppet::ParseError, 
        'properies_to_augeas(): Wrong number of arguments given (3 for 1..2)'
      )
  end
  
  it 'should throw Puppet::ParseError if passing wrong type of arguments' do
    should run.
      with_params(true, []).
        and_raise_error(
          Puppet::ParseError,
          "properies_to_augeas(): Wrong type of arguments given (TrueClass for Hash, Array for Array)"
        )
  end

end