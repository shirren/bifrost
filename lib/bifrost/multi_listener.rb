require 'azure'

module Bifrost
  # This class is used to handle the setup and execution of multiple listeners
  class MultiListener
    attr_reader :listeners

    def initialize
      @listeners ||= []
    end

    # A listener can be added to the collection of current listeners
    # setup on the system
    def add(listener)
      @listeners << listener unless listener.nil?
    end

    # When we run all the listeners are processed in there own thread. This run also blocks to make sure
    # the spawned threads remain operational indefinitely
    def run
      t = Thread.new do
        byebug
        listeners.each do |l|
          Thread.new { l.run }.join
        end
      end
      t.join
    end
  end
end
