require 'azure'
require 'celluloid/current'
require_relative 'entity'
require_relative 'exceptions/unsupported_lambda_error'

module Bifrost
  # This class is used to read messages from the subscriber, and process the messages one
  # by one. This class is a worker/actor which focusses on processes a single topic/subscriber
  # combination one at a time
  class Worker < Entity
    include Celluloid
    include Celluloid::Internals::Logger
    include Celluloid::Notifications

    attr_reader :topic, :subscriber, :callback, :options

    # Initialise the worker/actor. This actually starts the worker by implicitly calling the run method
    def initialize(topic, subscriber, callback, options = {})
      raise Bifrost::Exceptions::UnsupportedLambdaError, 'callback is not a proc' unless callback.respond_to?(:call)
      @topic ||= topic
      @subscriber ||= subscriber
      @callback ||= callback
      @options ||= options
      super()
      info("Worker #{self} starting up...")
      publish('worker_ready', topic, subscriber)
    end

    # This method starts the actor, which runs in an infinite loop. This means the worker should
    # not terminate, but if it does, the supervisor will make sure it restarts
    def run
      info("Worker #{self} running...")
      loop do
        info("Worker #{self} waking up...") if Bifrost.debug?
        read_message
        info("Worker #{self} going to sleep...") if Bifrost.debug?
        sleep(ENV['QUEUE_DELAY'] || 10)
      end
    end

    # Workers have a friendly name which is a combination of the topic and subscriber name
    # which in the operational environment should be unique
    def to_s
      Worker.handle(topic, subscriber)
    end

    # Utlity method to get the name of the worker as a symbol
    def to_sym
      to_s.to_sym
    end

    # A worker can tell you what it's friendly name will be, this is in order for supervision
    def self.handle(topic, subscriber)
      "#{topic.downcase}--#{subscriber.downcase}"
    end

    private

    # Actual processing of the message
    def read_message
      raw_message = @bus.interface.receive_subscription_message(topic, subscriber, timeout: ENV['TIMEOUT'] || 10)
      if raw_message
        info("Worker #{self} picked up message #{raw_message}") if Bifrost.debug?
        message = Bifrost::Message.new(raw_message)
        if options[:non_repeatable]
          @bus.interface.delete_subscription_message(raw_message)
          callback.call(message)
        else
          callback.call(message)
          @bus.interface.delete_subscription_message(raw_message)
        end
      elsif Bifrost.debug?
        info("Worker #{self} no message...")
      end
    end
  end
end
