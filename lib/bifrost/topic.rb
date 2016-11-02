require 'azure'
require_relative 'entity'
require_relative 'exceptions/duplicate_subscriber_error'

module Bifrost
  # Topics are central to the pub/sub system in the Bifrost. All messages must be delivered
  # to a topic. The topic is responsible for forwarding the message to registered subscribers
  class Topic < Entity
    attr_reader :name

    def initialize(name)
      @name ||= name
      super()
    end

    # If the topic has been defined this method returns true, if not
    # it returns false
    def exists?
      @bus.topics.each do |topic|
        return true if topic.name == name
      end
      false
    end

    # If a topic has not been defined we can save it, so it becomes defined
    def save
      if exists?
        false
      else
        @bus.interface.create_topic(name)
        true
      end
    end

    # If a topic is defined, we can remove the definition
    def delete
      if exists?
        @bus.interface.delete_topic(name)
        true
      else
        false
      end
    end

    # A new subscriber can be added to a topic
    def add_subscriber(subscriber)
      if exists?
        begin
          @bus.interface.create_subscription(name, subscriber.name)
        rescue Azure::Core::Http::HTTPError => e
          return false if e.status_code == 409
          raise e
        end
        true
      else
        false
      end
    end

    # A topic subscriber can be removed from the topic if it exists
    def remove_subscriber(subscriber)
      if exists?
        begin
          @bus.interface.delete_subscription(name, subscriber.name)
        rescue Azure::Core::Http::HTTPError => e
          return false if e.status_code == 404
          raise e
        end
        true
      else
        false
      end
    end
  end
end
