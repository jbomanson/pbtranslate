require "../gate"

module PBTranslator
  record Visitor::ArraySwap(T), array : Array(T) do
    include Gate::Restriction

    def visit(f : Comparator.class, s : InPlace.class, wires) : Void
      i, j = wires
      a = @array[i]
      b = @array[j]
      c = a < b
      @array[i] = c ? a : b
      @array[j] = c ? b : a
    end

    # On some machine, the following is a 1.15x slower version of the above.
    # def visit_comparator(i, j) : Void
    #   a, b = @array.values_at(i, j)
    #   unless a < b
    #     @array.swap(i, j)
    #   end
    # end
  end
end
