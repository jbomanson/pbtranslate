require "../util"

module PBTranslate::Util
  # A no-op method that takes a _value_ of _type_.
  #
  # This is useful for restricting a value to the intersection of chosen types.
  # ### Example
  #
  #     include PBTranslate
  #
  #     module AA
  #     end
  #
  #     module BB
  #     end
  #
  #     class XX
  #       include AA
  #       include BB
  #     end
  #
  #     x = XX.new
  #     Util.restrict(x, AA)
  #     Util.restrict(x, BB)
  #     Util.restrict(x, XX)
  #
  #     # Util.restrict(x, Float) # => No overload matches ...
  def self.restrict(value, type)
    restrict_reverse(type, value)
  end

  private def self.restrict_reverse(type : E.class, value : E) : Nil forall E
  end

  private def self.restrict_reverse(type, value) : Nil
    {{ raise "Type restriction failed" }}
  end

  def self.restrict_not(value, type)
    restrict_not_reverse(type, value)
  end

  # A no-op method that returns a _value_ as long as it is not of a `Union` type
  # that contains Nil.
  # Otherwise a compile time error is raised.
  #
  # ### Example
  #
  # ```
  # include PBTranslate::Util
  #
  # # These are OK.
  # restrict_not_nilable_union(1)              # 1 : Int32
  # restrict_not_nilable_union("a")            # "a" : String
  # restrict_not_nilable_union(true ? 1 : "a") # 1 : (Int32 | String)
  # restrict_not_nilable_union(nil)            # nil : Nil
  #
  # # This is caught during compilation.
  # restrict_not_nilable_union(true ? 1 : nil)
  # # => Expected anything but a nilable union type, got (Int32 | Nil)
  # ```
  def restrict_not_nilable_union(value : U) : U forall U
    {% if U.union? && U.union_types.find &.==(Nil) %}
      {{ raise "Expected anything but a nilable union type, got #{U}" }}
    {% end %}
    value
  end

  # A no-op method that returns a _value_ as long as it is a `Tuple` in which
  # all element types are the same.
  # Otherwise a compile time error is raised.
  #
  # ### Example
  #
  # ```
  # include PBTranslate::Util
  #
  # # This is OK.
  # restrict_tuple_uniform({1, 2, 3})
  #
  # # This is caught during compilation.
  # restrict_tuple_uniform({1, 2, "b"})
  # # => Expected a tuple type repeating a single type, got
  # # Tuple(Int32, Int32, String)
  # ```
  def restrict_tuple_uniform(tuple : U) : U forall U
    {% if U.type_vars.uniq.size != 1 %}
      {{ raise "Expected a tuple type repeating a single type, got #{U}" }}
    {% end %}
    tuple
  end

  private def self.restrict_not_reverse(type : E.class, value : E) : Nil forall E
    {{ raise "Negated type restriction failed" }}
  end

  private def self.restrict_not_reverse(type, value) : Nil
  end
end
