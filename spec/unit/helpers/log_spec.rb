require 'spec_helper'

require_corresponding __FILE__

describe 'Colorize', :unit do
  it 'should not crash when making string bold' do
    'a'.bold
    'a'.red.on_blue.bold
    'a'.bold.red
  end
end

describe Log, :unit do
  it 'should not crash when logging' do
    LOG.show_hello
    LOG.fatal_hello { 'hello' }
    LOG.hide_hello
    LOG.fatal_hello { 'hello' }
    lambda { LOG.hutehteuo }.should raise_error
  end
end
