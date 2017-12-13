struct PBTranslate::Visitor::Print
  include Gate::Restriction
  include Visitor
  include Visitor::DefaultMethods

  def initialize
  end

  def visit_gate(g : Gate(Comparator, InPlace, _), memo, *empty_args, level, **options)
    i, j = g.wires
    memo.puts "comparator(#{i}, #{j}, #{level})."
    memo
  end

  def visit_gate(g, memo, **options)
    memo
  end
end
