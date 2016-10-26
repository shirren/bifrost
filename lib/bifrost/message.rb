require 'azure'
require_relative 'entity'

module Bifrost
  # A message is a letter that we send to a topic. It must contain a subject and body
  # The receiver can process both fields on receipt of the message
  class Message < Bifrost::Entity
    attr_reader :subject, :body

    # A message must have a valid subject and body. The service
    # bus is initialised in the Entity class
    def initialize(subject, body)
      @subject ||= subject
      @body ||= body
      super()
    end

    # A message can be posted to a particular topic
    def post_to(topic)
      if topic.exists?
        message = Azure::ServiceBus::BrokeredMessage.new(subject, message: body)
        subscription = bus.send_topic_message(topic.name, message)
        return true if subscription
      end
      false
    end
  end
end
