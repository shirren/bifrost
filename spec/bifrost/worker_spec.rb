require 'spec_helper'
require 'bifrost'

describe Bifrost::Worker do
  let(:cb) { proc { |m| puts "Received: message #{m}" } }
  subject(:worker) { Bifrost::Worker.new('topic', 'subscriber', cb) }

  it { is_expected.to respond_to(:topic) }
  it { is_expected.to respond_to(:subscriber) }

  it 'should not except non procs in last argument' do
    expect { Bifrost::Worker.new('topic', 'subscriber', 'x') }
      .to raise_error(Bifrost::Exceptions::UnsupportedLambdaError)
  end

  it 'should have a friendly string name' do
    expect(worker.to_s).to eq("#{worker.topic}--#{worker.subscriber}")
  end

  it 'should downcase the friendly name' do
    another_worker = Bifrost::Worker.new('toPic', 'subScriber', cb)
    expect(another_worker.to_s).to eq("#{another_worker.topic.downcase}--#{another_worker.subscriber.downcase}")
  end

  it 'should have a friendly symbol name' do
    expect(worker.to_sym).to eq(worker.to_s.to_sym)
  end

  skip 'should be able to listen for messages' do
    topic = Bifrost::Topic.new('topic')
    topic.save
    subscriber = Bifrost::Subscriber.new('subscriber')
    topic.add_subscriber(subscriber)
    msg = Bifrost::Message.new([item1: { data: 2 }, item2: { more_data: 3 }])
    msg.publish(topic)
    expect(msg.status).to eq(:delivered)
    expect(msg.message_id).not_to be_nil
    worker.async.run
    sleep
  end
end
