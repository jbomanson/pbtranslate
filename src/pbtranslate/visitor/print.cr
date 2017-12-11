struct PBTranslate::Visitor::Print
  include Gate::Restriction
  include Visitor
  include Visitor::DefaultMethods

  def initialize(@io : IO)
  end

  def visit_gate(g : Gate(Comparator, InPlace, _), *empty_args, depth, **options) : Nil
    i, j = g.wires
    @io.puts "comparator(#{i}, #{j}, #{depth})."
  end

  def visit_gate(g, **options) : Nil
  end
end
