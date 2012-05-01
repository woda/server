require 'msgpack'

module MessagePack
  class EventUnpacker
    attr_accessor :on_parse_complete

    def initialize
      @unpacker = MessagePack::Unpacker.new
    end

    def << data
      @unpacker.feed_each(data) do |obj|
        @on_parse_complete.(obj) if @on_parse_complete
      end
    end
  end
end
