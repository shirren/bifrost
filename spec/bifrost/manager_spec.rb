require 'spec_helper'
require 'bifrost'

describe Bifrost::Manager do
  let(:cb)      { proc { |m| puts "Principle Received: message #{m}" } }
  let(:worker)  { Bifrost::Worker.new('topic', 'subscriber', proc) }
  let(:manager) { Bifrost::Manager.new }

  skip 'should be able to help a faulty actor heal' do
    manager.add('topicX', 'blah', proc { |m| puts "Secondary Received: message #{m}" })
    manager.run
  end
end
