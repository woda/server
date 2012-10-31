require 'spec_helper'

require_corresponding __FILE__

describe SyncController, :unit do
  before do
    @connection = ClientConnection.new host: '0.0.0.0', part: 12345
    @controller = SyncController.new @connection
  end

  it "should ask for file content for file upload" do
    content = 'hello'
    @controller.param['content_hash'] = WodaHash.digest(content).to_hex
    @controller.param['filename'] = 'abc'
    # TODO: test token and message symbol
    @connection.should_receive(:send_message)
    @controller.put
  end
end
