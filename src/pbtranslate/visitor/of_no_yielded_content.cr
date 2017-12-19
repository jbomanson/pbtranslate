module PBTranslate::Visitor::OfNoYieldedContent
  def visit_region(gate : Gate, &block)
    raise "Gates with yielded content are not supported in this context"
  end
end
