require 'azure'
require_relative 'entity'

module Bifrost
  # A message is a letter that we send to a topic. It must contain a subject and body
  # The receiver can process both fields on receipt of the message
  class Message < Entity
    attr_reader :meta, :body, :status, :message_id

    alias resource_id message_id
    alias id message_id

    # A message must have a valid subject and body. The service
    # bus is initialised in the Entity class
    def initialize(body, meta = {})
      @meta = meta
      if body.is_a?(Azure::ServiceBus::BrokeredMessage)
        merge(body)
      else
        @body ||= body
        @status ||= :undelivered
      end
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

    # A message when serialised to a string just renders the messag identifier
    def to_s
      id
    end

    private

    # Merges this message with the required properties of the raw Azure brokered message
    # The sender might send a message other than JSON in which case we just send the raw data along
    def merge(raw_message)
      @status = :delivered
      begin
        @meta = raw_message.properties
        @body = JSON.parse(raw_message.body)
      rescue JSON::ParserError
        @body = raw_message
      end
      @message_id = raw_message.message_id
    end

    # Create the message and attempt to deliver It
    def send_message(topic, message)
      @bus.interface.send_topic_message(topic.name, message)
      update_message_state_to_delivered(message)
    end

    # Create the brokered message, note that the Bifrost message supports native
    # ruby hashes, but during the transport these messages are converted to JSON
    # strings
    def create_brokered_message
      payload = body.respond_to?(:to_json) ? body.to_json : body
      message = Azure::ServiceBus::BrokeredMessage.new(payload, meta)
      message.message_id = SecureRandom.uuid
      message
    end

    # Update the status of the message post delivery
    def update_message_state_to_delivered(message)
      @status = :delivered
      @message_id = message.message_id
    end
  end
end
