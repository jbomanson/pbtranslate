struct PBTranslate::Visitor::Print
  include Visitor
  include Visitor::DefaultMethods

  def initialize(@io : IO)
  end

  def visit_gate(g : Gate::Comparator, **options, depth) : Nil
    i, j = g.wires
    @io.puts "comparator(#{i}, #{j}, #{depth})."
  end

  def visit_gate(g, **options) : Nil
  end
end
