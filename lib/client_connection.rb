require 'eventmachine'

class ClientConnection < EventMachine::Connection
  def receive_data data
    send_data data
  end
end
