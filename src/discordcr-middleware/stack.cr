module Discord
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
