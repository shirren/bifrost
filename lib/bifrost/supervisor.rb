require 'azure'
require 'celluloid'
require_relative 'exceptions/invalid_worker_definition_error'

module Bifrost
  # This class is used to handle the setup and execution of multiple listeners
  class Supervisor
    include Celluloid

    # The supervisor needs to be notified when a worker dies
    trap_exit :worker_died

    attr_reader :worker_definitions

    def initialize
      @worker_definitions ||= []
    end

    # A listener can be added to the collection of current listeners
    # setup on the system
    def add(topic_name, subscriber_name, &proc)
      if topic_name.nil? || subscriber_name.nil? || proc.nil?
        raise InvalidWorkerDefinitionError, 'Invalid worker'
      else
        # Celluloid::Actor[worker.to_sym] = worker
        #  # Link the worker to the supervisor so if the worker misbehaves the supervisor is alerted
        #  # to this poor behaviour, the supervisor decides how to handle recovery
        # self.link(worker)
        @worker_definitions << { topic_name: topic_name, subscriber_name: subscriber_name, proc: proc }
      end
    end

    # When we run all the listeners are processed in there own thread. This run also blocks to make sure
    # the spawned threads remain operational indefinitely
    def run
      byebug
      supervisor = SupervisionGroup.run!
      workers.each do |worker|
        supervisor.pool(Worker, as: :workers, args: [], size: 2)
        supervisor[:workers].run
      end
    end

    private

    # This callback function fires when an worker dies
    def  worker_died(worker, reason)
      # TODO: Log this instead
      puts "#{worker} has died: #{reason.class}"
    end
  end
end
