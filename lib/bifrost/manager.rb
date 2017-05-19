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
    def add(topic, subscriber, proc, options = {})
      if topic.nil? || subscriber.nil? || proc.nil?
        raise InvalidWorkerDefinitionError, 'Invalid worker'
      else
        Worker.supervise(as: Worker.handle(topic, subscriber), args: [topic, subscriber, proc, append_default_options(options)])
      end
    end

    # When we run all the workers as actors in their own threads. This run also blocks to make sure
    # the spawned threads remain operational indefinitely
    def run
      # Put the supervisor thread to sleep indefinitely
      loop do
        # TODO: Perhaps there is a better way?
        sleep(60)
      end
    end

    # This callback is fired when the worker signals it is ready to commence work after initialisation or
    # recommence after recovering from a failure.
    # When a worker completes initialisation it can take a while for the worker to be registered as an Actor
    # in Celluloid, for this reason we need need to put a minor delay in the initialisation procedure
    def worker_ready(*args)
      info("Worker bootstrapping with #{args}...")
      sleep(ENV['BIFROST_BOOTSTRAP_DELAY'] || 2) # TODO: Perhaps there is a better way?
      worker = get_worker(args[1], args[2])
      if worker
        # Link the worker to the supervisor so if the worker misbehaves the supervisor is alerted
        # to this poor behaviour, the supervisor decides how to handle recovery
        link(worker)
        worker.async.run
      else
        error("Worker bootstrap failure with #{args}")
      end
    end

    private

    ##
    # Create default options hash if custom options do not exit
    def append_default_options(custom_options)
      options = { non_repeatable: false }
      options.merge(custom_options)
    end

    # Retrieve a worker through the supervisory structure, this can take a while as the worker might
    # be going through a restart procedure by the actor framework
    def get_worker(topic, subscriber)
      handle = Worker.handle(topic, subscriber)
      Celluloid::Actor[handle.to_sym]
    end

    # This callback function fires when an worker dies
    def worker_died(worker, reason)
      error("Worker #{worker.inspect} has died: #{reason.class}")
    end
  end
end
