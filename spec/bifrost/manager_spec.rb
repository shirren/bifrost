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

  it 'should append default options to empty options param' do
    manager.add('topicX', 'blah', proc { |m| puts "Secondary Received: message #{m}" })
    expect(manager.send(:append_default_options, {})).to eq({ non_repeatable: false })
  end

  it 'should append default options to custom options param' do
    manager.add('topicX', 'blah', proc { |m| puts "Secondary Received: message #{m}" })
    expect(manager.send(:append_default_options, { custom_option: true })).to eq({ custom_option: true, non_repeatable: false })
  end
end
