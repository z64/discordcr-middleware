module Discord
  # A stage in a `Stack` when processing a message.
  # To create custom middleware, inherit from this class and define a
  # `def done(context, done)` method.
  # The first argument is a `Context` that contains the invoking message
  # and the client, as well as any additional properties you have added.
  # To call the next middleware in the chain, call `done.call`. If you
  # don't do this, the middleware stack will stop at that point.
  abstract class Middleware
    abstract def call(context, done)
  end

  # A collection of `Middleware` that can be processed by
  # passing a `Message` to `Stack#run`.
  class Stack
    getter client : Client

    def initialize(@client, *middlewares)
      @middlewares = [] of Middleware
      middlewares.each { |m| @middlewares << m }
      @block = nil
    end

    def initialize(@client, *middlewares, &block : Context ->)
      @middlewares = [] of Middleware
      middlewares.each { |m| @middlewares << m }
      @block = block
    end

    # Runs a message through this middleware stack
    def run(message : Message)
      context = Context.new(client, message)
      self.next(0, context)
    end

    # Advances to the next middleware in the chain
    def next(index, context)
      if mw = @middlewares[index]?
        mw.call context, ->{ self.next(index + 1, context) }
      end
    end
  end
end
