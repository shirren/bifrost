require 'azure'
require_relative 'entity'

module Bifrost
  # This class is used to read messages from the subscriber
  class Listener < Bifrost::Entity
    attr_reader :topic_name, :subscriber_name

    def initialize(topic_name, subscriber_name)
      @topic_name ||= topic_name
      @subscriber_name ||= subscriber_name
      super()
    end

    # We should be able to pass a function to the subscriber. When the subscriber receives the message
    # it should invoke the specific function passing the message received from the topic
    def process(&proc)
      loop do
        # If a message is received then we sleep for a bit. If no message exists, the message
        # bus will wait for a pre-defined period before which the request times out. For this
        # reason we use the nested loop, because we do not want to innundate the bus with too
        # many requests too quickly
        sleep(ENV['QUEUE_DELAY'] || 10) while read_message(proc)
      end
    end

    private

    # Actual processing of the message
    def read_message(proc)
      message = bus.receive_subscription_message(topic_name, subscriber_name)
      if message
        proc.call(message.properties['message'])
        bus.delete_subscription_message(message)
      end
      true
    rescue StandardError
      # TODO: Log all standard errors
      false # TODO: Fix this
    end
  end
end
