require 'spec_helper'

require_corresponding __FILE__

describe Protocol::Serializer, :unit do
  it "should handle JSON" do
    Protocol::Serializer.new :json
    Protocol::Serializer.new :JSON
    Protocol::Serializer.new 'json'
    Protocol::Serializer.new 'Json'
  end

  it "should handle msgpack" do
    Protocol::Serializer.new :msgpack
    Protocol::Serializer.new :MSGPACK
    Protocol::Serializer.new 'msgpack'
    Protocol::Serializer.new 'mSGpack'
  end

  it "should raise ArgumentError unless JSON or msgpack" do
    lambda { Protocol::Serializer.new 'lol' }.should raise_error(ArgumentError)
  end

  def has_proper_interface serializer
    serializer.pack.should respond_to(:encode)
    serializer.unpack.should respond_to(:<<)
    serializer.unpack.should respond_to(:on_parse_complete=)
  end

  it "should instanciate the correct interfaces if JSON" do
    serializer = Protocol::Serializer.new 'json'
    has_proper_interface serializer
  end

  it "should instanciate the correct interfaces if msgpack" do
    serializer = Protocol::Serializer.new 'msgpack'
    has_proper_interface serializer
  end

  TEST_HASH = { "hello" => 3, "3.0" => "lol", "4" => -10.0, "pokemon" => [102, "a", { "a" => 10}, 1.0] }
  NB_SERIALIZE = 3

  def test_serializer_parse_what_it_produces serializer, hash
    obj = mock()
    obj.should_receive(:fct).with(hash).exactly(NB_SERIALIZE).times
    serializer.unpack.on_parse_complete = obj.method(:fct)
    chunks = 0
    NB_SERIALIZE.times do
      serializer.pack.encode hash do |chunk|
        serializer.unpack << chunk
        chunks += 1
      end
    end
    chunks
  end

  it "should parse the JSON it produces" do
    serializer = Protocol::Serializer.new 'json'
    test_serializer_parse_what_it_produces serializer, TEST_HASH
  end

  it "should unpack the msgpack it produces" do
    serializer = Protocol::Serializer.new 'msgpack'
    test_serializer_parse_what_it_produces serializer, TEST_HASH
  end

  def generate_huge_hash
    hash = {}
    50.times do |i|
      hash["a" * i] = "b" * i
      hash["c" * i] = [10, 20.0] * i
    end
    hash
  end

  it "should receive several chunks with a huge hash in JSON" do
    serializer = Protocol::Serializer.new 'JSON'
    times = test_serializer_parse_what_it_produces(serializer, generate_huge_hash)
    (times / NB_SERIALIZE).should be >= 2
  end

  it "should receive several chunks with a huge hash in msgpack" do
    serializer = Protocol::Serializer.new 'msgpack'
    times = test_serializer_parse_what_it_produces(serializer, generate_huge_hash)
    (times / NB_SERIALIZE).should be >= 2
  end

  it "should handle several successive JSON objects" do
    serializer = Protocol::Serializer.new 'JSON'
  end

  it "should handle several successive msgpack objects" do
    serializer = Protocol::Serializer.new 'msgpack'
  end
end
