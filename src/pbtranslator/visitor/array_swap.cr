require "../gate"

record PBTranslator::Visitor::ArraySwap(T), array : Array(T) do
  include Gate::Restriction

  def visit(gate : Gate(Comparator, InPlace, _), way : Forward, **options) : Void
    i, j = gate.wires
    a = @array[i]
    b = @array[j]
    c = a < b
    @array[i] = c ? a : b
    @array[j] = c ? b : a
  end

  def visit(gate : Gate(Passthrough, _, _), way : Forward, **options) : Void
  end

  def visit(layer : Layer, way : Forward, **options) : Void
    yield self
  end

  # On some machine, the following is a 1.15x slower version of the above.
  # def visit_comparator(i, j) : Void
  #   a, b = @array.values_at(i, j)
  #   unless a < b
  #     @array.swap(i, j)
  #   end
  # end
end
