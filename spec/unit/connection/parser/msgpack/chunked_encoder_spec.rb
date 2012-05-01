require 'spec_helper'

require_corresponding __FILE__

describe MessagePack::ChunkedEncoder do
  before do
    @encoder = MessagePack::ChunkedEncoder.new
  end

  it "should simulate a very basic stream" do
    @encoder.should respond_to(:<<)
    @encoder << "hello"
  end

  HASH = { "hello" => 3, "3.0" => "lol", "4" => -10.0, "pokemon" => [102, "a", { "a" => 10}, 1.0] }

  it "should encode to msgpack" do
    res = ""
    @encoder.encode(HASH) { |msgpack| res << msgpack }
    res.should be == HASH.to_msgpack
  end

  class CheckInfiniteRecursion
    attr_reader :failed

    def initialize encoder
      @encoder = encoder
    end

    def recv_msgpack chunck
      if @called
        @failed = true
        return
      end
      @called = true
      @encoder << chunck
    end
  end

  it "should not enter infinite recursion" do
    checker = CheckInfiniteRecursion.new @encoder
    @encoder.encode({}, &checker.method(:recv_msgpack))
    checker.failed.should_not be
  end
end
