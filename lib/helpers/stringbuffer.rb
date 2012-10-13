# This maintains a separate read and write location

class StringBuffer
  def initialize
    @buffer = ''
  end

  def read
    buf = @buffer
    @buffer = ''
    buf
  end

  def << data
    buf << data
  end

  def nextline
    position = @buffer.index("\n")
    return nil unless position
    ret = @buffer[0..position]
    @buffer = @buffer[position..len(@buffer)]
    ret
  end

  def method_missing name, *args, &block
    @buffer.send(name, args, block)
  end
end
