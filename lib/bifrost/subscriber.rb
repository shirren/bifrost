require 'azure'

module Bifrost
  # A subscriber is a type that registers interest in receiving messages posted to certain topics
  class Subscriber
    attr_reader :name, :options

    def initialize(name, options = {})
      @name ||= name
      @options ||= options
    end
  end
end
