struct PBTranslate::LagArray(T)
  # A wrapper over a `LagArray(T)` through which all writes are delayed.
  struct Lagged(T)
    protected def initialize(@update_array : LagArray(T))
    end

    # The underlying `Array`.
    delegate to_a, to: @update_array

    # Return a value assigned before the creation of this lagged object.
    delegate :[], to: to_a

    # Schedule an assignment to be done at a later moment.
    def []=(index : Int32, value : T)
      @update_array.updates << {index, value}
    end
  end

  # The underlying `Array`.
  def to_a
    @array
  end

  protected getter updates

  # Creates a `LagArray` that is backed internally by the given `array`.
  def initialize(@array : Array(T))
    @updates = Array({Int32, T}).new
  end

  # Delegated to the underlying array.
  delegate :[], :[]=, to: to_a

  # Yields a `Lagged` object for accessing this array with the property that
  # all assignments through it are applied only after the block is done.
  #
  #     a = LagArray.new([:a, :b])
  #     a.lag do |lagged|
  #       lagged[0] = lagged[1]
  #       lagged[1] = lagged[0]
  #     end
  #     a.to_a # => [:b, :a]
  def lag : Nil
    lagged = Lagged.new(self)
    yield lagged
    @updates.each do |index, value|
      @array[index] = value
    end
    @updates.clear
  end
end
