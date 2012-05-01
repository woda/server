require 'spec_helper'

require_corresponding __FILE__

describe MessagePack::EventUnpacker do
  before do
    @unpacker = MessagePack::EventUnpacker.new
  end

  it "should be able to set on_parse_complete" do
    @unpacker.should respond_to(:on_parse_complete)
    @unpacker.should respond_to(:on_parse_complete=)
  end

  NB_MESSAGEPACK = 3

  it "should parse MessagePack and call on_parse_complete" do
    obj = mock()
    obj.should_receive(:fct).with({}).exactly(NB_MESSAGEPACK).times
    @unpacker.on_parse_complete = obj.method(:fct)
    NB_MESSAGEPACK.times do
      @unpacker << {}.to_msgpack
    end
  end

  HASH = { "hello" => 3, "3.0" => "lol", "4" => -10.0, "pokemon" => [102, "a", { "a" => 10}, 1.0] }

  it "should handle separated chunks" do
    msgpack = HASH.to_msgpack
    obj = mock()
    obj.should_receive(:fct).with(HASH).exactly(msgpack.length).times
    @unpacker.on_parse_complete = obj.method(:fct)
    msgpack.length.times do |i|
      @unpacker << msgpack[0...i]
      @unpacker << msgpack[i..-1]
    end
  end
end
