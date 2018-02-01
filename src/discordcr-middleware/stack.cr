module Discord
  # A stage in a `Stack` when processing a message.
  # To create custom middleware, inherit from this class and define a
  # `def done(context, done)` method.
  # The first argument is a `Context` that contains the invoking message
  # and the client, as well as any additional properties you have added.
  # To call the next middleware in the chain, call `done.call`. If you
  # don't do this, the middleware stack will stop at that point.
  abstract class Middleware
    def call(context, done)
      raise {{@type.stringify}} + " does not support #{context.class}!"
    end
  end

  # A collection of `Middleware` that can be processed by
  # passing a `Message` to `Stack#run`.
  class Stack
    def initialize(*middlewares)
      @middlewares = [] of Middleware
      middlewares.each { |m| @middlewares << m }
    end

    # Runs a message through this middleware stack, with a trailing block
    def run(context : Context(T), index = 0, &block : Context(T) ->) forall T
      if mw = @middlewares[index]?
        mw.call context, ->{ run(context, index + 1, &block) }
      else
        block.call(context)
      end
    end

    # Runs a message through this middleware stack
    def run(context : Context(T), index = 0) forall T
      @middlewares[index]?.try do |mw|
        mw.call context, ->{ run(context, index + 1) }
      end
    end
  end
end
