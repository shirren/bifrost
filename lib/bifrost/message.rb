require 'azure'
require_relative 'entity'

module Bifrost
  # A message is a letter that we send to a topic. It must contain a subject and body
  # The receiver can process both fields on receipt of the message
  class Message < Entity
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
    def publish(topic)
      if topic.exists?
        send_message(topic, create_brokered_message)
        true
      else
        false
      end
    end

    # A message can be posted to a particular topic, if the message is succssfully delivered
    # we return a unique identifier for the message
    def publish!(topic)
      if topic.exists?
        send_message(topic, create_brokered_message)
        message_id
      else
        raise Bifrost::Exceptions::MessageDeliveryError, "Could not post message to #{topic}"
      end
    end

    private

    # Create the message and attempt to deliver It
    def send_message(topic, message)
      @bus.interface.send_topic_message(topic.name, message)
      update_message_state_to_delivered(message)
    end

    # Create the brokered message
    def create_brokered_message
      message = Azure::ServiceBus::BrokeredMessage.new(subject, message: body)
      message.correlation_id = SecureRandom.uuid
      message
    end

    # Update the status of the message post delivery
    def update_message_state_to_delivered(message)
      @status = :delivered
      @message_id = message.correlation_id
    end
  end
end
