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

  private def self.restrict_not_reverse(type : E.class, value : E) : Nil forall E
    {{ raise "Negated type restriction failed" }}
  end

  private def self.restrict_not_reverse(type, value) : Nil
  end
end
