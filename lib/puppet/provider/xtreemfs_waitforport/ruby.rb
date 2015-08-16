# A puppet provider for type :xtreemfs_waitforport
Puppet::Type.type(:xtreemfs_waitforport).provide(:ruby) do
  desc "Manages xtreemfs_waitforport"

  def open
    expected = resource[:open]
    ip = resource[:ip]
    if is_port_open?(ip, expected, 0.001)
      expected
    else
      nil
    end
  end

  def open=(port)
    expected = resource[:open]
    ip = resource[:ip]
    unless is_port_open?(ip, expected, resource[:timeout])
      raise Puppet::Error, "Port #{expected.inspect} is not open after waiting #{resource[:timeout]} seconds"
    end
  end

  private

  def is_port_open?(ip, port, timeout)
    require 'socket'
    require 'timeout'
    begin
      Timeout::timeout(timeout) do
        while true
          begin
            s = TCPSocket.new(ip, port)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            # wait
            sleep 0.1
          end
        end
      end
    rescue Timeout::Error
    end

    return false
  end
end