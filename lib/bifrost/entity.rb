require 'azure'

module Bifrost
  # Types that require access to the message bus should inherit this type. We've chosen
  # inheritance at this point, perhaps a mixin might be a better approach
  class Entity
    def initialize
      @bus ||= Bifrost::Bus.new
    end
  end
end
