module PBTranslate::Visitor::OfNoYieldedContent
  def visit_gate(g, **options, &block) : Nil
    raise "Gates with yielded content are not supported in this context"
  end
end
