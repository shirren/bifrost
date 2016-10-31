require 'spec_helper'
require 'bifrost/message'
require 'bifrost/topic'
require 'bifrost/subscriber'

describe Bifrost::Message do
  subject(:message) { Bifrost::Message.new({ content: 'some data' }, 'subscriber_name') }

  it { is_expected.to respond_to(:subject) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:message_id) }
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:post_to) }

  context 'which is initialized' do
    it 'should be in an undelivered status' do
      expect(message.status).to eq(:undelivered)
    end
  end

  it 'should be able to auto generate a subject' do
    new_message = Bifrost::Message.new(content: 'some data')
    expect(new_message).to_not be_nil
  end

  it 'should be postable to a valid topic' do
    topic = Bifrost::Topic.new('valid-topic')
    topic.save
    topic.add_subscriber(Bifrost::Subscriber.new('new_subscriber'))
    expect(message.post_to(topic)).to be_truthy
    expect(message.status).to eq(:delivered)
    expect(message.message_id).not_to be_nil
    topic.delete
  end

  it 'should not be postable to an invalid topic' do
    topic = Bifrost::Topic.new('invalid-topic') # A topic that is neither saved, nor with no subscribers is semantically invalid
    expect(message.post_to(topic)).to be_falsey
  end
end
