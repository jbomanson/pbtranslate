require "../gate"

class PBTranslator::Network::DirectMerge
  include Gate::Restriction

  def initialize(@half_width_log2 : Distance)
  end

  def size : Distance
    half_width = Distance.new(1) << @half_width_log2
    x = half_width + 1
    x * x - 1
  end

  def depth : Distance
    @half_width_log2 == 0 ? Distance.new(1) : Distance.new(2)
  end

  # Arranges a visit over the AND and OR gates in this network placed at an
  # *offset*.
  def host(visitor, way : Way, at offset : Distance = Distance.new(0)) : Nil
    visitor.visit_region(OOPSublayer) do |layer_visitor|
      base = Int64.new(offset - 1)
      half_width = Int64.new(1) << @half_width_log2
      a = Int64.new(1)
      b = half_width << 1
      way.each_between(a, b) do |out_value| # This is one indexed.
        present_layer(layer_visitor, way, base, half_width, out_value)
      end
    end
  end

  # Arranges a visit to an OR gate in a layer.
  private def present_layer(
                      layer_visitor, way, base, half_width, out_value)
    wire = Distance.new(out_value + base)
    layer_visitor.visit_gate(Gate.or_as(Distance.new(wire))) do |or_visitor|
      a = {Int64.new(0), out_value - half_width}.max
      b = {half_width, out_value}.min
      way.each_between(a, b) do |left_value|
        present_or(
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
  private def present_or(
                       or_visitor, way, base, half_width, out_value, left_value)
    right_value = out_value - left_value
    g = and_input_gate(base, half_width, left_value, right_value)
    or_visitor.visit_gate(g)
  end

  private def and_input_gate(base, half_width, left_value, right_value)
    values =
      if 1 <= left_value
        if 1 <= right_value
          {left_value, half_width + right_value}
        else
          {left_value}
        end
      else
        {half_width + right_value}
      end
    wires = values.map { |value| Distance.new(value) }
    Gate.and_of(tuple: wires).shifted_by(base)
  end
end
