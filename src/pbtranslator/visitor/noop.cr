# A singleton visitor that does nothing.
struct PBTranslator::Visitor::Noop
  # An instance of a visitor that does nothing.
  INSTANCE = new

  # Does nothing.
  def visit_gate(*args, **options) : Void
  end
end
