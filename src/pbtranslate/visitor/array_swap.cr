require "../gate"

record PBTranslate::Visitor::ArraySwap(T), array : Array(T) do
  include Gate::Restriction
  include Visitor

  def visit_gate(g : Gate(Comparator, InPlace, _), **options) : Nil
    i, j = g.wires
    a = @array[i]
    b = @array[j]
    c = a < b
    @array[i] = c ? a : b
    @array[j] = c ? b : a
  end

  def visit_gate(g : Gate(Passthrough, _, _), **options) : Nil
  end

  def visit_region(layer : Layer) : Nil
    yield self
  end
end
