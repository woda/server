module MessagePack
  class ChunkedEncoder
    def initialize
      @stream = FakeStream.new self
    end

    def encode obj, &block
      @proc = block
      obj.to_msgpack @stream
      @proc = nil
    end

    def on_chunk chunk
      @proc.(chunk) if @proc
    end

    class FakeStream
      def initialize encoder
        @encoder = encoder
      end

      def << chunk
        encoder.on_chunk chunk
      end
    end
  end
end
