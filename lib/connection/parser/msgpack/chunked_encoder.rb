require 'msgpack'

module MessagePack
  class ChunkedEncoder
    def encode obj, &block
      @proc = block
      obj.to_msgpack self
      @proc = nil
    end

    def << chunk
      proc = @proc
      @proc = nil
      proc.(chunk) if proc
      @proc = proc
    end
  end
end
