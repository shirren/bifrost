require 'azure'
require 'celluloid/current'
require_relative 'exceptions/invalid_worker_definition_error'

module Bifrost
  # This class is used to handle the setup and execution of multiple listeners
  class Manager
    include Celluloid
    include Celluloid::Internals::Logger
    include Celluloid::Notifications

    # The supervisor needs to be notified when a worker dies, it also needs to
    # protect itself from harm
    trap_exit :worker_died

    # Initialisation of the Manager sets up a subscriber, which informs the manager
    # when the worker is ready to begin work
    def initialize
      subscribe('worker_ready', :worker_ready)
    end

    # A supervised worker can be added to the current collection of supervised workers
    # this also starts the actor
    def add(topic, subscriber, proc)
      if topic.nil? || subscriber.nil? || proc.nil?
        raise InvalidWorkerDefinitionError, 'Invalid worker'
      else
        @supervisor = Worker.supervise(as: Worker.handle(topic, subscriber), args: [topic, subscriber, proc])
      end
    end

    # When we run all the workers as actors in their own threads. This run also blocks to make sure
    # the spawned threads remain operational indefinitely
    def run!
      # Put the supervisor thread to sleep indefinitely # Better way?
      loop do
        # TODO: Better way?
        sleep(5)
      end
    end

    # This callback is fired when the worker signals it is ready to recommence work
    def worker_ready(*args)
      info("Worker bootstrapping with #{args}...")
      worker_handle = Worker.handle(args[1], args[2])
      sleep(2)
      worker = Celluloid::Actor[worker_handle.to_sym]
      if worker
        # Link the worker to the supervisor so if the worker misbehaves the supervisor is alerted
        # to this poor behaviour, the supervisor decides how to handle recovery
        link(worker)
        worker.async.run
      end
    end

    private

    # This callback function fires when an worker dies
    def worker_died(worker, reason)
      error("Worker #{worker.inspect} has died: #{reason.class}")
    end
  end
end
