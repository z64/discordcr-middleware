require "discordcr"
require "./discordcr-middleware/*"

module Discord
  class Client
    getter stacks = {} of Symbol => Stack

    # Registers a new `Stack` with a unique ID and a path of middleware to run
    def stack(id : Symbol, *middleware)
      @stacks[id] = Stack.new(self, *middleware)
    end

    # Registers a new `Stack` with a unique ID and a path of middleware to run
    def stack(id : Symbol, *middleware, &block : Context ->)
      @stacks[id] = Stack.new(self, *middleware, &block)
    end

    # Returns the stack stored under `id`
    def stack(id : Symbol)
      @stacks[id]
    end

    # Passes a message through the registered stacks
    def run_stack(message : Message)
      @stacks.each do |id, stack|
        stack.run(message)
      end
    end

    def initialize(token : String, client_id : UInt64? = nil,
                   shard : Gateway::ShardKey? = nil,
                   large_threshold : Int32 = 100,
                   compress : Bool = false,
                   properties : Gateway::IdentifyProperties = DEFAULT_PROPERTIES)
      previous_def(token, client_id, shard, large_threshold, compress, properties)

      # We add a "default" message event handler that runs incoming messages
      # across our middleware stacks
      on_message_create do |message|
        run_stack(message)
      end
    end
  end
end
