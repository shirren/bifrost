require 'azure'
require 'celluloid'
require_relative 'entity'
require_relative 'exceptions/unsupported_lambda_error'

module Bifrost
  # This class is used to read messages from the subscriber, and process the messages one
  # by one. This class is a worker/actor which focusses on processes a single topic/subscriber
  # combination one at a time
  class Worker < Bifrost::Entity
    include Celluloid

    attr_reader :topic_name, :subscriber_name, :proc

    def initialize(topic_name, subscriber_name, proc)
      raise Bifrost::Exceptions::UnsupportedLambdaError, 'not a proc' unless proc.respond_to?(:call)
      @topic_name ||= topic_name
      @subscriber_name ||= subscriber_name
      @proc ||= proc
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

    private

    # Actual processing of the message
    def read_message
      message = bus.receive_subscription_message(topic_name, subscriber_name, timeout: ENV['TIMEOUT'] || 5)
      if message
        proc.call(message.properties['message'])
        bus.delete_subscription_message(message)
      end
    rescue StandardError => e
      # We suppress exceptions to make this library more fault tolerant. The intetnet
      # can be unpredictable yeah?
      # TODO: Log all standard errors instead of puts
      puts e
    end
  end
end
