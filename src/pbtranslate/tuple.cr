struct Tuple
  # Calls `object.call(memo, element, *args, **options)` for each *element* in
  # this tuple, where *memo* is either *initial_value* or the return value of
  # the previous call.
  #
  # This is different from `Tuple#reduce`, which uses yield.
  # This is important, because the types of the values yielded in any method are
  # upcasted to the union of all of them.
  #
  # ### Example
  #
  # In Crystal 0.24.1, expressions such as `{[1], ["x"]}.sum` and
  # `{{1}, {"x"}}.sum` fail during compilation.
  # This is a workaround:
  #
  # ```
  # {[1], ["x"]}.pbtranslate_reduce_with_receiver(Adder.new, [] of NoReturn)
  # # => [1, "x"] : Array(Int32 | String)
  #
  # { {1}, {"x"} }.pbtranslate_reduce_with_receiver(Adder.new, Tuple.new)
  #
  # # => [1, "x"] : {Int32, String}
  #
  # struct Adder
  #   def call(memo, element)
  #     memo + element
  #   end
  # end
  # ```
  def pbtranslate_reduce_with_receiver(
    object,
    initial_value,
    *args,
    **options
  )
    memo = initial_value
    {% for i in 0...T.size %}
      memo = object.call(memo, self[{{i}}], *args, **options)
    {% end %}
    memo
  end
end
