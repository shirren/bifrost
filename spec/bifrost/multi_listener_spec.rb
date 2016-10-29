require 'spec_helper'
require 'bifrost'

describe Bifrost::MultiListener do

  it 'should contain an empty listener collection on creation' do
    multi_listener = Bifrost::MultiListener.new
    expect( multi_listener.listeners ).to eq( [] )
  end

  it 'should be able to configure multiple listeners' do
    # topic1 = Bifrost.create_topic_with_subscriber('topic1', 'subscriber1')
    # topic2 = Bifrost.create_topic_with_subscriber('topic2', 'subscriber2')
    topic1 = Bifrost::Topic.new('topic1')
    topic2 = Bifrost::Topic.new('topic2')
    # Bifrost::Message.new(body = { data: 'data1' }).post_to(topic1)
    # Bifrost::Message.new(body = { data: 'data2' }).post_to(topic2)
    l1 = Bifrost::Listener.new( 'topic1', 'subscriber1', Proc.new { |m| "Received message #{m} on sub 1" } )
    l2 = Bifrost::Listener.new( 'topic2', 'subscriber2', Proc.new { |m| "Received message #{m} on sub 2" } )
    multi_listener = Bifrost::MultiListener.new
    multi_listener.add( l1 )
    multi_listener.add( l2 )
    multi_listener.run # Should block at this point
  end
end
