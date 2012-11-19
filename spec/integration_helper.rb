TEST_PORT = 12345

require 'eventmachine'

module IntegrationHelperImplementation
  def around_connection_timeout between=nil
    proc = Proc.new { raise 'timeout' }
    around_connection_implementation(proc, between) { yield }
  end

  def around_connection between=nil
    proc = Proc.new { }
    around_connection_implementation(proc, between) { yield }
  end

  def around_connection_implementation proc, between
    EventMachine::run do
      EventMachine::start_server '0.0.0.0', TEST_PORT, (is_ssl ? ClientSslConnection : ClientConnection)
      @connection = EM.connect '0.0.0.0', TEST_PORT, (is_ssl ? FakeSslConnection : FakeConnection)
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
    @post_inited = false
  end

  def receive_data(data)
    @data << data
    @registered[:receive_data].(data) if @registered[:receive_data]
  end

  def unbind
    @onclose.call if @onclose
  end

  def post_init
    if @registered.include? :post_init then
      @registered[:post_init].()
    else
      @post_inited = true
    end
  end

  def register_post_init &block
    if @post_inited then
      block.()
    else
      @registered[:post_init] = block
    end
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
