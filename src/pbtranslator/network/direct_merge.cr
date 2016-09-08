require "../gate"

module PBTranslator

  class Network::DirectMerge(I)
    include Gate::Restriction

    def initialize(@half_width_log2 : I)
    end

    def size
      half_width = I.new(1) << @half_width_log2
      x = half_width + 1
      x * x - 1
    end

    def depth
      @half_width_log2 == 0 ? I.new(1) : I.new(2)
    end

    # :nodoc:
    macro visitors(prefix, visit_expr)

      def {{prefix.id}}visit(visitor, offset = I.new(0))
        visitor.{{prefix.id}}visit(OOPLayer) do |layer_visitor|
          base = offset - 1
          half_width = I.new(1) << @half_width_log2
          a = I.new(1)
          b = half_width << 1
          {{visit_expr}} do |out_value| # This is one indexed.
            {{prefix.id}}visit_or(layer_visitor, base, out_value, half_width)
          end
        end
      end

      # Arranges a visit to an OR gate in a layer.
      private def {{prefix.id}}visit_or(
        layer_visitor, base, out_value, half_width)

        wire = out_value + base
        layer_visitor.{{prefix.id}}visit(Gate.or_as(wire)) do |or_visitor|
          a = {I.new(0), out_value - half_width}.max
          b = {half_width, out_value}.min
          {{visit_expr}} do |left_value|
            {{prefix.id}}visit_and(or_visitor, base, out_value, left_value)
          end
        end
      end

      # Arranges a visit to an AND gate connected to an OR gate.
      private def {{prefix.id}}visit_and(or_visitor, base, out_value, left_value)
        right_value = out_value - left_value
        gate = and_input_gate(base, left_value, right_value)
        or_visitor.{{prefix.id}}visit(gate)
      end

    end

    private def and_input_gate(base, left_value, right_value)
      wires =
        if 1 <= left_value
          if 1 <= right_value
            {left_value, right_value}
          else
            {right_value}
          end
        else
          {left_value}
        end
      Gate.and_of(tuple: wires).shifted_by(base)
    end

    # Arranges a visit over the AND and OR gates in this network placed at an
    # *offset*.
    visitors "", a.upto(b)

    # Like `#visit` but in reverse order and calling reverse_visit instead.
    visitors reverse_, b.downto(a)

  end

end
