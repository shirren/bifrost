require 'spec_helper'
require 'bifrost'

describe Bifrost::Manager do
  let(:proc)    { Proc.new { |m| puts "Principle Received: message #{m}" }}
  let(:worker)  { Bifrost::Worker.new('topic', 'subscriber', proc) }
  let(:manager) { Bifrost::Manager.new }

  skip 'should contain an empty worker collection on creation' do
    expect(manager.supervisors).to eq([])
  end

  skip 'should be able to help a faulty actor heal' do
    manager.add('topicX', 'blah', Proc.new { |m| puts "Secondary Received: message #{m}" })
    manager.run
  end
end
