require 'azure'
require 'celluloid/current'
require_relative 'entity'
require_relative 'exceptions/unsupported_lambda_error'

module Bifrost
  # This class is used to read messages from the subscriber, and process the messages one
  # by one. This class is a worker/actor which focusses on processes a single topic/subscriber
  # combination one at a time
  class Worker < Bifrost::Entity
    include Celluloid

    attr_reader :topic_name, :subscriber_name, :callback

    def initialize(topic_name, subscriber_name, callback)
      raise Bifrost::Exceptions::UnsupportedLambdaError, 'not a proc' unless callback.respond_to?(:call)
      @topic_name ||= topic_name
      @subscriber_name ||= subscriber_name
      @callback ||= callback
      super()
    end

    # This method starts the actor, which runs in an infinite loop. This means the worker should
    # not terminate, but if it does, the supervisor will make sure it restarts
    def run
      loop do
        read_message
        sleep(ENV['QUEUE_DELAY'] || 10)
      end
    end

    # Workers have a friendly name which is a combination of the topic and subscriber name
    # which in the operational environment should be unique
    def to_s
      Worker.supervisor_handle(topic_name, subscriber_name)
    end

    # Utlity method to get the name of the worker as a symbol
    def to_sym
      to_s.to_sym
    end

    # A worker can tell you what it's friendly name will be, this is in order for supervision
    def self.supervisor_handle(topic_name, subscriber_name)
      "#{topic_name}-#{subscriber_name}"
    end

    private

    # Actual processing of the message
    def read_message
      message = bus.receive_subscription_message(topic_name, subscriber_name, timeout: ENV['TIMEOUT'] || 10)
      if message
        callback.call(message.properties['message'])
        bus.delete_subscription_message(message)
      end
    end
  end
end
