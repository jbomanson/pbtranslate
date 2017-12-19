require "./first_class"
require "../gate"
require "../network"

class PBTranslate::Network::Pw2MergeDirect
  include FirstClass
  include Gate::Restriction
  include Network

  BASE = Int64.new(-1)

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

  # Arranges a visit over the AND and OR gates in this network.
  def host_reduce(visitor, memo)
    visitor.visit_region(OOPSublayer) do |layer_visitor|
      half_width = Int64.new(1) << @half_width_log2
      a = Int64.new(1)
      b = half_width << 1
      visitor.way.each_in(a..b) do |out_value| # This is one indexed.
        wire = Distance.new(out_value + BASE)
        layer_visitor.visit_region(Gate.or_as(Distance.new(wire))) do |or_visitor|
          a = {Int64.new(0), out_value - half_width}.max
          b = {half_width, out_value}.min
          visitor.way.each_in(a..b) do |left_value|
            right_value = out_value - left_value
            gate = and_input_gate(half_width, left_value, right_value)
            memo = or_visitor.visit_gate(gate, memo, drop_true: nil)
          end
        end
      end
    end
    memo
  end

  private def and_input_gate(half_width, left_value, right_value)
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
    wires = values.map { |value| Distance.new(value + BASE) }
    Gate.and_of(tuple: wires)
  end
end
