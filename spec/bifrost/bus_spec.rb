require 'spec_helper'

describe Bifrost::Bus do
  let(:bus) { Bifrost::Bus.new }

  context 'for an undefined topic' do
    it 'should return false for defined?' do
      new_topic = Bifrost::Topic.new('new-topic')
      expect(bus.topic_exists?(new_topic)).to be_falsey
    end
  end

  context 'for a defined topic' do
    it 'should return true for defined?' do
      topic = Bifrost::Topic.new('bus-topic')
      topic.save
      dup_topic = Bifrost::Topic.new('bus-topic')
      expect(bus.topic_exists?(dup_topic)).to be_truthy
    end
  end
end
