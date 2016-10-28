require 'spec_helper'
require 'bifrost/listener'
require 'bifrost/message'
require 'bifrost/topic'
require 'bifrost/subscriber'

describe Bifrost::Listener do
  subject(:listener) { Bifrost::Listener.new('topic', 'subscriber') }

  it { is_expected.to respond_to(:topic_name) }
  it { is_expected.to respond_to(:subscriber_name) }

  skip 'should be able to listen for messages, only use outside of specs' do
    topic = Bifrost::Topic.new('topic')
    # topic.save
    # subscriber = Bifrost::Subscriber.new('subscriber')
    # topic.add_subscriber(subscriber)
    msg = Bifrost::Message.new(body = [item1: { data: 2 }, item2: { more_data: 3 }])
    msg.post_to(topic)
    expect(msg.status).to eq(:delivered)
    expect(msg.message_id).not_to be_nil
    listener.process do |message|
      puts "Received: message #{message}"
    end
  end
end
