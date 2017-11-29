module Discord
  # A container for shared state throughout processing of a message
  class Context
    getter client : Client

    getter message : Message

    def initialize(@client : Client, @message : Message)
    end
  end

  # Adds a `property` to `Context`
  macro add_ctx_property(name, type)
    class ::Discord::Context
      property {{name}} : {{type}}
    end
  end

  # Adds a `property!` to `Context`
  macro add_ctx_property!(name, type)
    class ::Discord::Context
      property! {{name}} : {{type}}
    end
  end
end

