class Object
  def pbtranslator_as(type)
    Object.pbtranslator_as_helper(type, self) { |x| yield x }
  end

  protected def self.pbtranslator_as_helper(type : E.class, value : E, &block) forall E
    value
  end

  protected def self.pbtranslator_as_helper(type, value, &block)
    yield value
  end
end
