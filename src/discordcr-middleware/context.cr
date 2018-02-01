module Discord
  # A container for shared state throughout processing of a message
  class Context(P)
    getter client : Client

    getter payload : P

    getter state = {} of String => Nil | String | Int32 | Int64 | Float64 | Bool

    property int : Int16 | Int32 | Int64 | Nil
    property uint : UInt16 | UInt32 | UInt64 | Nil
    property string : String?
    property float : Float32 | Float64 | Nil
    property bool : Bool?

    def initialize(@client : Client, @payload : P)
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
