TEST_PORT = 12345

require 'eventmachine'

module IntegrationHelperImplementation
  def around_connection_timeout
    proc = Proc.new { raise 'timeout' }
    around_connection_implementation(proc) { yield }
  end

  def around_connection
    proc = Proc.new { }
    around_connection_implementation(proc) { yield }
  end

  def around_connection_implementation proc
    EventMachine::run do
      EventMachine::start_server '0.0.0.0', TEST_PORT, (is_ssl ? ClientSslConnection : ClientConnection)
      @connection = EM.connect '0.0.0.0', PORT, (is_ssl ? FakeSslConnection : FakeConnection)
      build_timer(1, &proc)
      yield
    end
  end

  def build_timer timeout, &fct
    @on_timeout = fct
    @timer = EventMachine::Timer.new(timeout) do
      @on_timeout.()
      EventMachine::stop
    end
  end
end

module SslIntegrationHelper
  include IntegrationHelperImplementation

  def is_ssl
    true
  end
end

module IntegrationHelper
  include IntegrationHelperImplementation

  def is_ssl
    false
  end
end

class FakeConnection < EventMachine::Connection

  attr_reader :data

  def initialize
    @data = []
    @registered = {}
  end

  def receive_data(data)
    @data << data
    @registered[:receive_data].(data) if @registered[:receive_data]
  end

  def unbind
    @onclose.call if @onclose
  end

  def method_missing name, *args, &block
    if name.to_s =~ /^register_(.*)$/
      mod = Module.new do
        define_method $1 do |*args|
        super(*args)
        block.(*args)
        end
      end
      self.extend mod
    else
      super
    end
  end
end

class FakeSslConnection < FakeConnection
  def post_init
    super
    start_tls
  end
end
