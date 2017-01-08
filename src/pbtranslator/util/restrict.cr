module PBTranslator::Util
  # A no-op method that takes a _value_ of _type_.
  #
  # This is useful for restricting a value to the intersection of chosen types.
  # ### Example
  #
  #     include PBTranslator
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

  private def self.restrict_reverse(type : E.class, value : E) : Void forall E
  end

  def self.restrict_not(value, type)
    restrict_not_reverse(type, value)
  end

  private def self.restrict_not_reverse(type : E.class, value : E) : Void forall E
    -"Type restriction failed"
  end

  private def self.restrict_not_reverse(type, value) : Void
  end
end
