require 'spec_helper'

describe 'directory_address', :type => :puppet_function do

  before :each do
    allow(Facter).to receive(:value).with(:fqdn).and_return('maestro.localdomain')
  end

  it 'should throw Puppet::ParseError if passing 0 args' do
    should run.
      with_params().and_raise_error(
        Puppet::ParseError, 
        'directory_address(): Wrong number of arguments given (0 for 3..4)'
      )
  end

  it 'should give "maestro.localdomain" for nil,nil,nil,nil' do
    should run.with_params(nil,nil,nil,nil).and_return('maestro.localdomain')
  end
  it 'should give "localhost" for "localhost",nil,nil,nil' do
    should run.with_params("localhost",nil,nil,nil).and_return('localhost')
  end
  it 'should give "maestro.localdomain:12345" for nil,12345,nil,nil' do
    should run.with_params(nil,12345,nil,nil).and_return('maestro.localdomain:12345')
  end
  it 'should give "pbrpcs://maestro.localdomain" for nil,nil,"pbrpcs",nil' do
    should run.with_params(nil,nil,"pbrpcs",nil).and_return('pbrpcs://maestro.localdomain')
  end
  it 'should give "pbrpcs://localhost:12345" for "localhost",12345,"pbrpcs",nil' do
    should run.with_params("localhost",12345,"pbrpcs",nil).and_return('pbrpcs://localhost:12345')
  end

  it 'should give "pbrpcs://master.vm:61465" for nil,nil,nil,"pbrpcs://master.vm:61465"' do
    should run.with_params(nil,nil,nil,"pbrpcs://master.vm:61465").and_return('pbrpcs://master.vm:61465')
  end
  it 'should give "pbrpcs://localhost:61465" for "localhost",nil,nil,"pbrpcs://master.vm:61465"' do
    should run.with_params("localhost",nil,nil,"pbrpcs://master.vm:61465").and_return('pbrpcs://localhost:61465')
  end
  it 'should give "pbrpcs://master.vm:12345" for nil,12345,nil,"pbrpcs://master.vm:61465"' do
    should run.with_params(nil,12345,nil,"pbrpcs://master.vm:61465").and_return('pbrpcs://master.vm:12345')
  end
  it 'should give "pbrpc://master.vm:61465" for nil,nil,"pbrpc","pbrpcs://master.vm:61465"' do
    should run.with_params(nil,nil,"pbrpc","pbrpcs://master.vm:61465").and_return('pbrpc://master.vm:61465')
  end
  it 'should give "pbrpcs://localhost:12345" for "localhost",12345,"pbrpcs","pbrpcs://master.vm:61465"' do
    should run.with_params("localhost",12345,"pbrpc","pbrpcs://master.vm:61465").and_return('pbrpc://localhost:12345')
  end
end