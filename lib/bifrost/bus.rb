require 'Azure'

module Bifrost
  # This type represents the Bifrost as a managed entity
  class Bus
    attr_reader :bus

    def initialize
      Azure.sb_namespace = ENV['NAMESPACE']
      host = "https://#{Azure.sb_namespace}.servicebus.windows.net"
      signer = Azure::ServiceBus::Auth::SharedAccessSigner.new(ENV['KEY_NAME'], ENV['KEY_SECRET'])
      @bus ||= Azure::ServiceBus::ServiceBusService.new(host, signer: signer)
    end
  end
end