require 'spec_helper'
require 'bifrost'

describe Bifrost::Message do
  subject(:message) { Bifrost::Message.new({ content: 'some data' }, 'subscriber_name') }

  it { is_expected.to respond_to(:subject) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:message_id) }
  it { is_expected.to respond_to(:body) }
  it { is_expected.to respond_to(:publish) }
  it { is_expected.to respond_to(:publish!) }

  context 'which is initialized' do
    it 'should be in an undelivered status' do
      expect(message.status).to eq(:undelivered)
    end
  end

  it 'should be able to auto generate a subject' do
    new_message = Bifrost::Message.new(content: 'some data')
    expect(new_message).to_not be_nil
  end

  describe 'publish' do
    it 'should publish to a valid topic' do
      topic = Bifrost::Topic.new('valid-topic')
      topic.save
      topic.add_subscriber(Bifrost::Subscriber.new('new_subscriber'))
      expect(message.publish(topic)).to be_truthy
      expect(message.status).to eq(:delivered)
      expect(message.message_id).not_to be_nil
      topic.delete
    end

    it 'should not be postable to an invalid topic' do
      topic = Bifrost::Topic.new('invalid-topic') # A topic that is neither saved, nor with no subscribers is semantically invalid
      expect(message.publish(topic)).to be_falsey
    end
  end

  describe 'publish!' do
    it 'should publish to a valid topic and return the message id' do
      topic = Bifrost::Topic.new('valid-topic')
      topic.save
      topic.add_subscriber(Bifrost::Subscriber.new('new_subscriber'))
      response = message.publish!(topic)
      expect(response).not_to be_nil
      expect(message.status).to eq(:delivered)
      expect(message.message_id).not_to be_nil
      expect(response).to eq(message.message_id)
      topic.delete
    end

    it 'should update the message id on a replublish of the same messsage' do
      topic = Bifrost::Topic.new('valid-topic')
      topic.save
      topic.add_subscriber(Bifrost::Subscriber.new('new_subscriber'))
      response = message.publish!(topic)
      expect(response).not_to be_nil
      expect(message.status).to eq(:delivered)
      expect(message.message_id).not_to be_nil
      expect(response).to eq(message.message_id)
      upd_response = message.publish!(topic)
      expect(upd_response).not_to eq(response)
      topic.delete
    end

    it 'should raise an exception upon publish to an invalid topic' do
      topic = Bifrost::Topic.new('invalid-topic')
      expect { message.publish!(topic) }.to raise_error(Bifrost::Exceptions::MessageDeliveryError)
    end
  end
end
