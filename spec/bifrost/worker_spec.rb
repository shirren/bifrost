require 'spec_helper'
require 'bifrost/exceptions/unsupported_lambda_error'
require 'bifrost/message'
require 'bifrost/topic'
require 'bifrost/subscriber'
require 'bifrost/worker'

describe Bifrost::Worker do
  let(:proc) { Proc.new { |m| puts "Received: message #{m}" }}
  subject(:listener) { Bifrost::Worker.new('topic', 'subscriber', proc) }

  it { is_expected.to respond_to(:topic_name) }
  it { is_expected.to respond_to(:subscriber_name) }

  it 'should not except non procs in last argument' do
    expect { Bifrost::Worker.new('topic', 'subscriber', 'x') }
      .to raise_error(Bifrost::Exceptions::UnsupportedLambdaError)
  end

  skip 'should be able to listen for messages' do
    topic = Bifrost::Topic.new('topic')
    topic.save
    subscriber = Bifrost::Subscriber.new('subscriber')
    # topic.add_subscriber(subscriber)
    msg = Bifrost::Message.new(body = [item1: { data: 2 }, item2: { more_data: 3 }])
    msg.post_to(topic)
    expect(msg.status).to eq(:delivered)
    expect(msg.message_id).not_to be_nil
    listener.async.run
  end
end
