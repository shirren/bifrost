require 'azure'
require 'celluloid/current'
require_relative 'exceptions/invalid_worker_definition_error'

module Bifrost
  # This class is used to handle the setup and execution of multiple listeners
  class Manager
    include Celluloid

    # The supervisor needs to be notified when a worker dies
    trap_exit :worker_died

    # A supervised worker can be added to the current collection of supervised workers
    # this also starts the actor
    def add(topic_name, subscriber_name, proc)
      if topic_name.nil? || subscriber_name.nil? || proc.nil?
        raise InvalidWorkerDefinitionError, 'Invalid worker'
      else
        @supervisor = Worker.supervise(
          as: Worker.supervisor_handle(topic_name, subscriber_name),
          args: [topic_name, subscriber_name, proc]
        )
        worker = @supervisor.actors.last
        # Link the worker to the supervisor so if the worker misbehaves the supervisor is alerted
        # to this poor behaviour, the supervisor decides how to handle recovery
        self.link(worker)
      end
    end

    # When we run all the listeners are processed in there own thread. This run also blocks to make sure
    # the spawned threads remain operational indefinitely
    def run(options = {})
      @supervisor.actors.each do |worker|
        worker.async.run
      end

      # Put the supervisor thread to sleep indefinitely # Better way?
      loop do
        sleep(5)
      end
        # We give the workers a breather when they start up
      #   sleep(5)
      # end
      # container = Celluloid::Supervision::Container.new do
      #   puts "Init complete"
      # end
      # actor = container.add(
      #   type: Worker,
      #   as: Worker.supervisor_handle('topic', 'subscriber'),
      #   args: ['topic', 'subscriber', proc]
      # )
      # Celluloid::Supervision::Container.run!
    end

    private

    # This callback function fires when an worker dies
    def  worker_died(worker, reason)
      # TODO: Log this instead
      puts "#{worker.inspect} has died: #{reason.class}"
      worker.async.run
    end
  end
end
