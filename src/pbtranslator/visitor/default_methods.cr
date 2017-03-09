module PBTranslator::Visitor::DefaultMethods
  def visit_region(region) : Nil
    yield self
  end
end
