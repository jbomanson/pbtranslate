module PBTranslate::Visitor::OfNoYieldedContent
  def visit_gate(g, memo, **options, &block)
    raise "Gates with yielded content are not supported in this context"
  end
end
