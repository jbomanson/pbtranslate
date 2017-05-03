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
end
