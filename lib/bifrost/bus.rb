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
      signer = Azure::ServiceBus::Auth::SharedAccessSigner.new(ENV['AZURE_BUS_KEY_NAME'], ENV['AZURE_BUS_KEY_SECRET'])
      @interface ||= Azure::ServiceBus::ServiceBusService.new(host, signer: signer)
    end

    # This method returns a list of topics currently defined on the Bifrost
    def topics
      @interface.list_topics.map do |t|
        Topic.new(t.name)
      end
    end
  end
end