require "../gate"
require "./first_class"

class PBTranslator::Network::DirectMerge
  include FirstClass
  include Gate::Restriction

  def initialize(@half_width_log2 : Distance)
  end

  def network_depth : Distance
    @half_width_log2 == 0 ? Distance.new(1) : Distance.new(2)
  end

  # The number of unary and binary conjunctions in the network.
  private def network_conjunction_count : Area
    half_width = Distance.new(1) << @half_width_log2
    x = half_width + 1
    x * x - 1
  end

  private def half_width : Distance
    Distance.new(1) << @half_width_log2
  end

  private def network_unary_count : Area
    Area.new(half_width) * 2
  end

  private def network_binary_count : Area
    Area.new(half_width) * half_width
  end

  def network_read_count : Area
    network_unary_count + network_binary_count * 2
  end

  def network_width : Distance
    Distance.new(1) << (@half_width_log2 + 1)
  end

  def network_write_count : Area
    Area.new(network_width)
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
        wire = Distance.new(out_value + base)
        layer_visitor.visit_gate(Gate.or_as(Distance.new(wire))) do |or_visitor|
          a = {Int64.new(0), out_value - half_width}.max
          b = {half_width, out_value}.min
          way.each_between(a, b) do |left_value|
            right_value = out_value - left_value
            g = and_input_gate(base, half_width, left_value, right_value)
            or_visitor.visit_gate(g, drop_true: nil)
          end
        end
      end
    end
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
