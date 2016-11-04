require 'bifrost/bus'
require 'bifrost/entity'
require 'bifrost/message'
require 'bifrost/topic'
require 'bifrost/subscriber'
require 'bifrost/manager'
require 'bifrost/worker'
require 'celluloid'

# Bifrost is a pub/sub gem built on top of the Azure MessageBus system
module Bifrost
  # Workers and the infrastructure can log using the standard level of granularity affored to any
  # standard logger (i.e. info, debug, error levels etc)
  def self.logger=(log_provider)
    Celluloid.logger = log_provider
  end

  # Simple utlity that creates a topic and a single subscriber for the given
  # topic. The topic is returned
  def self.create_topic_with_subscriber(topic, subscriber)
    topic = Bifrost::Topic.new(topic)
    topic.save
    topic.add_subscriber(Bifrost::Subscriber.new(subscriber))
    topic
  end

  # Get an instance of the bus
  def self.bus
    Bifrost::Bus.new
  end

  # Creates a manager instance
  def self.manager
    Bifrost::Manager.new
  end
end
