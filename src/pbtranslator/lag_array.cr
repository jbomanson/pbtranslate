module PBTranslator

  struct LagArray(T)

    # A wrapper over a `LagArray(T)` through which all writes are delayed.
    struct Lagged(T)

      protected def initialize(@update_array : LagArray(T))
      end

      # The underlying `Array`.
      delegate array, to: @update_array

      # Return a value assigned before the creation of this lagged object.
      delegate :[], to: array

      # Schedule an assignment to be done at a later moment.
      def []=(index : Int32, value : T)
        @update_array.updates << {index, value}
      end

    end

    # The underlying `Array`.
    getter array

    protected getter updates

    # Creates a `LagArray` that is backed internally by the given `array`.
    def initialize(@array : Array(T))
      @updates = Array({Int32, T}).new
    end

    # Delegated to `#array`.
    delegate :[], :[]=, to: array

    # Yields a `Lagged` object for accessing this array so that all assignments
    # via the object are applied only once the block returns.
    #
    #     a = LagArray.new([:a, :b])
    #     a.lag do |lagged|
    #       lagged[0] = lagged[1]
    #       lagged[1] = lagged[0]
    #     end
    #     a.array # => [:b, :a]
    def lag : Void
      lagged = Lagged.new(self)
      yield lagged
      @updates.each do |index, value|
        @array[index] = value
      end
      @updates.clear
    end

  end

end