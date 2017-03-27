module PBTranslator::Visitor::DefaultMethods
  def visit_region(offset : Offset) : Nil
    {{ raise "Visits to offset regions must be handled explicitly" }}
    yield self
  end

  def visit_region(region) : Nil
    yield self
  end
end
