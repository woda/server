require 'spec_helper'
require 'connection/file_connection'

require_corresponding __FILE__

describe SyncController, :unit do
  before do
    @connection = ClientConnection.new host: '0.0.0.0', part: 12345
    @file_connection = FileConnection.new host: '0.0.0.0', port: 12346
    @controller = SyncController.new @connection
    @user = User.new login: 'a', email: 'abc@a.com', first_name: 'pokemon', last_name: 'pikachu'
    @user.set_password 'hello'
    @user.save
    @connection.data[:current_user] = @user

    EM.stub(:defer) { |f, callback| callback.(f.()) }
  end

  def upload_file
    content = 'hello'
    @controller.param['content_hash'] = WodaHash.digest(content).to_hex
    @controller.param['filename'] = 'abc'
    token = nil
    @connection.stub(:send_message) {}
    @connection.should_receive(:send_message).and_return  do |type, data|
      type.should eq(:file_need_upload)
      token = data[:token]
    end
    @connection.call_request :put, @controller
    token.should be

    WFile.first(filename: 'abc').should be_nil

    @connection.should_receive(:send_message).with(:file_received)
    @file_connection.receive_data token
    @file_connection.receive_data "\n"
    @file_connection.receive_data content
    @file_connection.unbind

    WFile.first(filename: 'abc').should_not be_nil
  end

  it "should ask for file content for file upload" do
    upload_file
  end

  it "should not ask for file content if it already exists" do
    upload_file
    @controller.param['content_hash'] = WodaHash.digest('hello').to_hex
    @controller.param['filename'] = 'bcd'
    @connection.should_receive(:send_message).with(:file_add_successful)
    @connection.call_request :put, @controller
    WFile.first(filename: 'bcd').should_not be_nil
  end

  it "should allow for deleting files" do
    upload_file
    @connection.should_receive(:send_message).with(:delete_successful)
    @connection.call_request :delete, @controller
    WFile.first(filename: 'abc').should be_nil
  end

  it "should allow for changing files" do
    upload_file
    @controller.param['content_hash'] = WodaHash.digest('helli').to_hex
    @connection.should_receive(:send_message).twice
    @connection.call_request :change, @controller
  end
end
