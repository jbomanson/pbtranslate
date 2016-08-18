require "./one_way"

module PBTranslator

  # An OEMerge scheme represents Batcher's odd-even merging networks.
  #
  # They are a class of _comparator networks_.
  # The gates in these networks are `Comparators`.
  #
  # The networks produced by this implementation merge pairs of consecutive
  # sequences.
  # Both sequences must have the same width and it must be a power of two.
  class Scheme::OEMerge

    record Network(I), half_width_log2 : I do

      def size
        (I.new(1) << half_width_log2) * half_width_log2 + 1
      end

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

      # Performs a visit over the comparators in a network for merging two
      # consecutive sequences of widths `1 << half_width_log2` that are placed at
      # an *offset*.
      #
      # For each visited comparator, `visitor.visit_comparator(a, b)` is called.
      define_visit "", a.upto(b)

      # Like `#visit` but in reverse order.
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

    INSTANCE = self.new

    def network(half_width_log2)
      Network.new(half_width_log2)
    end

  end

end
