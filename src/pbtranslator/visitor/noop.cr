require "./default_methods"

# A singleton visitor that does nothing.
struct PBTranslator::Visitor::Noop
  include Visitor
  include DefaultMethods

  # An instance of a visitor that does nothing.
  INSTANCE = new

  # Does nothing.
  def visit_gate(*args, **options) : Nil
  end
end
