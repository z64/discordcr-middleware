module Discord
  # A stage in a `Stack` when processing a message.
  # To create custom middleware, inherit from this class and define a
  # `def done(context, done)` method.
  # The first argument is a `Context` that contains the invoking message
  # and the client, as well as any additional properties you have added.
  # To call the next middleware in the chain, call `done.call`. If you
  # don't do this, the middleware stack will stop at that point.
  module Middleware
    abstract def call(context, payload, &block)
  end

  # A collection of `Middleware` that can be processed by
  # passing a `Message` to `Stack#run`.
  class Stack(*T)
    @middlewares : T

    def initialize(*middlewares : *T)
      @middlewares = middlewares
    end

    # Runs a message through this middleware stack, with a trailing block
    def run(payload : U, context : Context, index = 0, &block : U, Context ->) forall U
      if mw = @middlewares[index]?
        mw.call(payload, context) { run(payload, context, index + 1, &block) }
      else
        yield payload, context
      end
    end

    # Runs a message through this middleware stack
    def run(payload : U, context : Discord::Context, index = 0) forall U
      if mw = @middlewares[index]?
        mw.call(payload, context) { run(payload, context, index + 1) }
      end
    end
  end
end
