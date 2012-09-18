require 'spec_helper'
require 'integration_helper'

describe "Connection integration", :integration do
  include IntegrationHelper

  it "should call @on_timeout on timeout" do
    around_connection do
      @timer.cancel
      m = mock()
      m.should_receive :timeout
      build_timer 0.0001, &m.method(:timeout)
    end
  end

  shared_examples_for "connectable server" do
    it "should connect" do
      around_connection_timeout do
        @connection.register_connection_completed do
          EM.stop
        end
      end
    end

    def check_should_receive type
      around_connection do
        data = ""
        @connection.send_data type
        @connection.register_receive_data do |d|
          data << d
          hash = yield data rescue nil
          if hash
            hash['status'].should be == "ok"
            hash['type'].should be == 'connection_ok'
            hash['message'].should be
            EM.stop
          end
        end
      end
    end

    it "should receive 'JSON' and answer with JSON data" do
      check_should_receive "json\n" do |data|
        JSON.parse data
      end
    end

    it "should receive 'msgpack' and answer with msgpack data" do
      check_should_receive "msgpack\n" do |data|
        MessagePack::unpack data
      end
    end

    def check_should_receive_multiple_successive type, to, from
      around_connection do
        data = ""
        count = 0
        @connection.send_data type
        @connection.register_receive_data do |d|
          data << d
          hash = from.(data) rescue nil
          if hash && count < 15
            count += 1
            @connection.send_data(to.({}))
            data = ""
            if hash['status'] == 'ko' && hash['type'] == 'invalid_data'
              raise 'invalid data'
            end
          elsif hash
            EM.stop
          end
        end
      end
    end

    it "should handle successive msgpack requests properly" do
      check_should_receive_multiple_successive "msgpack\n",
        Proc.new {|data| data.to_msgpack},
        Proc.new {|data| MessagePack::unpack data}
    end

    it "should handle successive json requests properly" do
      check_should_receive_multiple_successive "json\n",
        Proc.new {|data| data.to_json},
        Proc.new {|data| JSON.parse data}
    end
  end

  it_behaves_like "connectable server"
end

describe "SSL connection integration", :integration do
  include SslIntegrationHelper

  it_behaves_like "connectable server"
end
