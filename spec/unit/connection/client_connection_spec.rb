require 'spec_helper'

require_corresponding __FILE__

describe ClientConnection do

  PORT = 12345

  before do
    @connection = ClientConnection.new host: '0.0.0.0', port: PORT
    @connection.should_receive(:send_data).any_number_of_times
  end

  it "should have a data hash" do
    @connection.data.should be == {}
    @connection.data = {"a" => 1}
    @connection.data.should be == {"a" => 1}
  end

  it "should have a set of messages" do
    @connection.messages
  end

  it "should allow choosing a JSON parser" do
    @connection.parser.should be_nil
    @connection.choose_parser "json\n"
    @connection.parser.should_not be_nil
  end

  it "should allow choosing a msgpack parser" do
    @connection.parser.should be_nil
    @connection.choose_parser "msgpack\n"
    @connection.parser.should_not be_nil
  end

  it "should not allow other parsers" do
    @connection.parser.should be_nil
    @connection.should_receive(:close_connection_after_writing)
    @connection.choose_parser "lol\n"
    @connection.parser.should be_nil
  end

  def generate_mocks
    obj = mock()
    obj.should_receive(:route).once.and_return("dummy")
    klass = mock()
    klass.should_receive(:new).with(@connection).once.and_return(obj)
    [klass, obj]
  end

  it "should be able to receive controler set" do
    klass, obj = generate_mocks
    @connection.push_controller_set [klass]
  end

  it "should parse route correctly" do
    @connection.choose_parser "json\n"
    klass, obj = generate_mocks
    obj.should_receive(:before_1).twice
    obj.should_receive(:before_2).once
    obj.should_receive(:action_1).once
    obj.should_receive(:before).once.and_return({:action_1 => [:before_1, :before_1, :before_2]})
    obj.should_receive(:actions).once.and_return(Set.new ['action_1'])
    request = {"action" => "dummy/action_1"}
    obj.should_receive(:param=).with(request)
    @connection.push_controller_set [klass]
    @connection.on_request(request)
  end
end

describe ClientSslConnection do
  it "should initialize tls" do
    # This is a bit complicated because we have to stub a method called
    # in the constructor...

    class TestSslConnection < ClientSslConnection
      def initialize
        should_receive(:start_tls)
        super
      end
    end
    @connection = TestSslConnection.new host: '0.0.0.0', port: PORT
  end
end
