require 'bifrost/message'
require 'bifrost/topic'
require 'bifrost/subscriber'
require 'bifrost/manager'
require 'bifrost/worker'

# Bifrost is a pub/sub gem built on top of the Azure MessageBus system
module Bifrost
  # Simple utlity that creates a topic and a single subscriber for the given
  # topic. The topic is returned
  def self.create_topic_with_subscriber(topic, subscriber)
    topic = Bifrost::Topic.new(topic)
    topic.save
    topic.add_subscriber(Bifrost::Subscriber.new(subscriber))
    topic
  end
end
