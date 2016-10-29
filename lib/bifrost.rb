require 'bifrost/listener'
require 'bifrost/multi_listener'
require 'bifrost/message'
require 'bifrost/topic'
require 'bifrost/subscriber'

# Bifrost is a pub/sub gem built on top of the Azure MessageBus system
module Bifrost
  # Simple utlity that creates a topic and a single subscriber for the given
  # topic. The topic is returned
  def self.create_topic_with_subscriber(topic_name, sub_name)
    topic = Bifrost::Topic.new(topic_name)
    topic.save
    subscriber = Bifrost::Subscriber.new(sub_name)
    topic.add_subscriber(subscriber)
    topic
  end
end
