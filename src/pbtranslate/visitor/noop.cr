require "./default_methods"

# A singleton visitor that does nothing.
struct PBTranslate::Visitor::Noop
  include Visitor
  include DefaultMethods

  # An instance of a visitor that does nothing.
  INSTANCE = new

  # Does nothing.
  def visit_gate(gate, memo, **options)
    memo
  end
end
