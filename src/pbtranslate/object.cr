class Object
  def pbtranslate_as(type)
    Object.pbtranslate_as_helper(type, self) { |x| yield x }
  end

  protected def self.pbtranslate_as_helper(type : E.class, value : E, &block) forall E
    value
  end

  protected def self.pbtranslate_as_helper(type, value, &block)
    yield value
  end

  # Calls `object.call(self, *args, **options)`.
  #
  # The purpose of this method is to force calls to be instantiated separately
  # for the possible types of a value.
  #
  # ### Example
  #
  # In this example, we have a value with the compile time type
  # `(Int32 | String)`.
  # Consequently, if we called a top level method that creates an array for it,
  # the array would be of type `Array(Int32 | String)`.
  #
  # However, we can also execute a call in such a way that the compiler
  # instantiates code for the two cases separately.
  # In this way, the type will be `Int32` in one instantiation and `String` in
  # in the other.
  # Also, if we called a method that creates an array in this way, the array
  # would be of type `Array(Int32) | Array(String)`.
  #
  #
  # ```
  # struct ArrayMaker
  #   def call(x)
  #     [x]
  #   end
  # end
  #
  # t = ArrayMaker.new
  # x = true ? 1 : ""                  # 1 : (Int32 | String)
  # x.pbtranslate_receive_call_from(t) # [1] (Array(Int32) | Array(String))
  # ```
  def pbtranslate_receive_call_from(object, *args, **options)
    object.call(self, *args, **options)
  end
end
