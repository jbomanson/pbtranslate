require "../gate"

record PBTranslator::Visitor::ArraySwap(T), array : Array(T) do
  include Gate::Restriction

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

  # On some machine, the following is a 1.15x slower version of the above.
  # def visit_comparator(i, j) : Nil
  #   a, b = @array.values_at(i, j)
  #   unless a < b
  #     @array.swap(i, j)
  #   end
  # end
end
