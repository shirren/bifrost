require 'Azure'

module Bifrost
  # Types that require access to the message bus should inherit this type. We've chosen
  # inheritance at this point, perhaps a mixin might be a better approach
  class Entity
    attr_reader :bus

    def initialize
      host = "https://#{Azure.sb_namespace}.servicebus.windows.net"
      signer = Azure::ServiceBus::Auth::SharedAccessSigner.new(ENV['KEY_NAME'], ENV['KEY_SECRET'])
      @bus ||= Azure::ServiceBus::ServiceBusService.new(host, signer: signer)
    end
  end
end
