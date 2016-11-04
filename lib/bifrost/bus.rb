require 'Azure'

module Bifrost
  # This type represents the Bifrost as a managed entity
  # NOTE: Warning, this object should never use shared state as it is referenced initialize
  # each worker
  class Bus
    attr_reader :interface

    def initialize
      Azure.sb_namespace = ENV['AZURE_BUS_NAMESPACE']
      host = "https://#{Azure.sb_namespace}.servicebus.windows.net"
      signer = Azure::ServiceBus::Auth::SharedAccessSigner.new(key, secret)
      @interface ||= Azure::ServiceBus::ServiceBusService.new(host, signer: signer)
    end

    # To encapsulate the underlying bus object we provide a custom interface
    # for the methods of the Azure smb we use
    def create_topic(name)
      @interface.create_topic(name)
    end

    def delete_topic(name)
      @interface.delete_topic(name)
    end

    # This method returns a list of topics currently defined on the Bifrost
    def topics
      @interface.list_topics.map do |t|
        Topic.new(t.name)
      end
    end

    # Tells us if the topic has already been defined
    def topic_exists?(topic)
      topics.include?(topic)
    end

    private

    # Simple utlity method to keep the code legible
    def key
      ENV['AZURE_BUS_KEY_NAME']
    end

    def secret
      ENV['AZURE_BUS_KEY_SECRET']
    end
  end
end
