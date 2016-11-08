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

    # Arranges a visit over the AND and OR gates in this network placed at an
    # *offset*.
    def host(visitor, way : Way, at offset = I.new(0))
      visitor.visit(OOPLayer, way) do |layer_visitor|
        base = offset - 1
        half_width = I.new(1) << @half_width_log2
        a = I.new(1)
        b = half_width << 1
        way.each_between(a, b) do |out_value| # This is one indexed.
          or_host(layer_visitor, way, base, half_width, out_value)
        end
      end
    end

    # Arranges a visit to an OR gate in a layer.
    private def or_host(
      layer_visitor, way, base, half_width, out_value)

      wire = out_value + base
      layer_visitor.visit(Gate.or_as(wire), way) do |or_visitor|
        a = {I.new(0), out_value - half_width}.max
        b = {half_width, out_value}.min
        way.each_between(a, b) do |left_value|
          and_host(
            or_visitor,
            way,
            base,
            half_width,
            out_value,
            left_value)
        end
      end
    end

    # Arranges a visit to an AND gate connected to an OR gate.
    private def and_host(
      or_visitor, way, base, half_width, out_value, left_value)

      right_value = out_value - left_value
      gate = and_input_gate(base, half_width, left_value, right_value)
      or_visitor.visit(gate, way)
    end

    private def and_input_gate(base, half_width, left_value, right_value)
      wires =
        if 1 <= left_value
          if 1 <= right_value
            {left_value, half_width + right_value}
          else
            {left_value}
          end
        else
          {half_width + right_value}
        end
      Gate.and_of(tuple: wires).shifted_by(base)
    end
  end
end
