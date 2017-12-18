require "../gate"

record PBTranslate::Visitor::ArraySwap(T), array : Array(T) do
  include Gate::Restriction
  include Visitor

  def visit_gate(gate : Gate(Comparator, InPlace, _), memo, **options)
    i, j = gate.wires
    a = @array[i]
    b = @array[j]
    c = a < b
    @array[i] = c ? a : b
    @array[j] = c ? b : a
    memo
  end

  def visit_gate(gate : Gate(Passthrough, _, _), memo, **options)
    memo
  end

  def visit_region(layer : Layer) : Nil
    yield self
  end
end
