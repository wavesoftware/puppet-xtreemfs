require 'spec_helper'

describe 'extra_to_augeas', :type => :puppet_function do
  it 'should return correct 4 element array after joining 2 element hash with 2 incoming augeas changes' do
    should run.
      with_params({ 
        'setting_one.to' => 5,
        :something => 'http://afsdfsd:222/'
      }, [
        'set dir_service.host http://localhost:30638',
        'set object_dir /var/lib/xtreemfs/objs'
      ]).
      and_return([
        'set setting_one.to 5',
        'set something http://afsdfsd:222/',
        'set dir_service.host http://localhost:30638',
        'set object_dir /var/lib/xtreemfs/objs'
      ])
  end
  it 'should throw Puppet::ParseError if passing 0 args' do
    should run.
      with_params().and_raise_error(
        Puppet::ParseError, 
        'extra_to_augeas(): Wrong number of arguments given (0 for 2)'
      )
  end
  it 'should throw Puppet::ParseError if passing 1 arg' do
    should run.
      with_params({}).and_raise_error(
        Puppet::ParseError, 
        'extra_to_augeas(): Wrong number of arguments given (1 for 2)'
      )
  end
  it 'should throw Puppet::ParseError if passing 3 and more args' do
    should run.
      with_params(1, 2, 3).and_raise_error(
        Puppet::ParseError, 
        'extra_to_augeas(): Wrong number of arguments given (3 for 2)'
      )
  end
end