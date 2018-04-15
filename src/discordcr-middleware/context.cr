module Discord
  # A container for shared state throughout processing of an event
  class Context
    @extensions = Hash(Int32, Void*).new

    # Access a stored value by class
    def [](clazz : T.class) : T forall T
      @extensions[clazz.crystal_type_id].unsafe_as(T)
    end

    # Store an object in this class. The object must be a `class`.
    def put(extension : T) forall T
      {% raise "Extension must be a class" unless T < Reference %}
      raise "BUG: Reference isn't sizeof(Void*)!" unless sizeof(typeof(extension)) == sizeof(Void*)
      @extensions[extension.class.crystal_type_id] = extension.unsafe_as(Pointer(Void))
    end
  end
end
