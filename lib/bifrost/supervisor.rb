require 'azure'

module Bifrost
  # This class is used to handle the setup and execution of multiple listeners
  class Supervisor
    attr_reader :workers

    def initialize
      @workers ||= []
    end

    # A listener can be added to the collection of current listeners
    # setup on the system
    def add(worker)
      @workers << worker unless worker.nil?
    end

    # When we run all the listeners are processed in there own thread. This run also blocks to make sure
    # the spawned threads remain operational indefinitely
    def run
    end
  end
end
