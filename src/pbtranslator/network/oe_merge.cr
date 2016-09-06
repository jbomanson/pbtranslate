module PBTranslator

# See `Scheme::OEMerge`.
class Network::OEMerge(I)

    # The binary logarithm of the width of the input halves of this network.
    getter half_width_log2

    # See `Scheme::OEMerge#network`.
    def initialize(@half_width_log2 : I)
    end

    # Returns the number of comparators in the network.
    def size
      (I.new(1) << half_width_log2) * half_width_log2 + 1
    end

    # Returns the number of comparators on the longest path from an input to
    # an output.
    def depth
      half_width_log2 + 1
    end

    # :nodoc:
    macro define_visit(prefix, each_expr)
      def {{prefix.id}}visit(visitor, offset = I.new(0))
        a, b = {I.new(0), half_width_log2}
        {{each_expr}} do |layer_index|
          {{prefix.id}}layer_visit(visitor, offset, layer_index)
        end
      end

      private def {{prefix.id}}layer_visit(visitor, offset, layer_index)
        a, b = {I.new(0), (I.new(1) << (half_width_log2 + 1)) - 1}
        {{each_expr}} do |wire_index|
          partner_index = partner(half_width_log2, layer_index, wire_index)
          next unless wire_index < partner_index
          comparator = Comparator.new(wire_index, partner_index)
          comparator = comparator.shifted by: offset
          visitor.{{prefix.id}}visit(comparator)
        end
      end
    end

    # Performs a visit over the comparators in this network placed at an
    # *offset*.
    #
    # The visit method of *visitor* is called for each comparator.
    define_visit "", a.upto(b)

    # Like `#visit` but in reverse order and calling reverse_visit instead.
    define_visit reverse_, b.downto(a)

    private def partner(half_width_log2, layer_index, wire_index)
      if I.new(0) == layer_index
        wire_index ^ (I.new(1) << half_width_log2)
      else
        r = half_width_log2 - layer_index
        s = wire_index >> r

        if {I.new(0), (I.new(1) << (layer_index + 1)) - 1}.includes? s
          wire_index # No comparator for this wire at this level.
        else
          wire_index - (1 - 2 * (s % 2)) * (1 << r)
        end
      end
    end

  end

end
