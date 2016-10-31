require 'azure'
require_relative 'entity'

module Bifrost
  # A message is a letter that we send to a topic. It must contain a subject and body
  # The receiver can process both fields on receipt of the message
  class Message < Bifrost::Entity
    attr_reader :subject, :body, :status, :message_id

    # A message must have a valid subject and body. The service
    # bus is initialised in the Entity class
    def initialize(body, subject = nil)
      @subject = subject || SecureRandom.base64
      @body ||= body
      @status ||= :undelivered
      super()
    end

    # A message can be posted to a particular topic
    def post_to(topic)
      if topic.exists?
        message = create_brokered_message
        bus.send_topic_message(topic.name, message)
        update_message_state_to_delivered(message)
        true
      else
        false
      end
    end

    private

    # Create the brokered message
    def create_brokered_message
      message = Azure::ServiceBus::BrokeredMessage.new(subject, message: body)
      message.correlation_id = SecureRandom.hex
      message
    end

    # Update the status of the message post delivery
    def update_message_state_to_delivered(message)
      @status = :delivered
      @message_id ||= message.correlation_id
    end
  end
end
