require 'yajl'
require 'msgpack'
require 'connection/parser/msgpack/event_unpacker'
require 'connection/parser/msgpack/chunked_encoder'

module Protocol
# This class guarantees that the unpack member will accept the method
# #on_parse_complete to set a callback and that the pack member will
# accept the method #encode which will yield each chunk to send.
  class Serializer
    attr_reader :pack, :unpack

    UNPACKERS = {
      'json' => Yajl::Parser,
      'msgpack' => MessagePack::EventUnpacker
    }

    PACKERS = {
      'json' => Yajl::Encoder,
      'msgpack' => MessagePack::ChunkedEncoder
    }

    def initialize name
      name = name.to_s.downcase
      @pack = PACKERS[name].new if PACKERS[name]
      @unpack = UNPACKERS[name].new if UNPACKERS[name]
      raise ArgumentError unless @pack && @unpack
    end
  end
end
