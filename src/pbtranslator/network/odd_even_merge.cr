require "../gate"

# See `Scheme::OddEvenMerge`.
struct PBTranslator::Network::OddEvenMerge
  include FirstClass

  # The binary logarithm of the width of the input halves of this network.
  getter half_width_log2

  # See `Scheme::OddEvenMerge#network`.
  def initialize(@half_width_log2 : Distance)
  end

  # Returns the number of comparators in the network.
  private def network_gate_count : Area
    Area.new(Distance.new(1) << half_width_log2) * half_width_log2 + 1
  end

  def network_depth : Distance
    half_width_log2 + 1
  end

  def network_read_count : Area
    network_write_count
  end

  def network_width : Distance
    Distance.new(1) << network_depth
  end

  def network_write_count : Area
    network_gate_count * 2
  end

  # Hosts a visit over the comparators in this network.
  #
  # The visit_gate method of *visitor* is called for each comparator.
  def host(visitor, way : Way) : Nil
    a, b = {Distance.new(0), half_width_log2}
    way.each_between(a, b) do |layer_index|
      layer_host(visitor, way, layer_index)
    end
  end

  private def layer_host(visitor, way, layer_index)
    a, b = {Distance.new(0), (Distance.new(1) << (half_width_log2 + 1)) - 1}
    way.each_between(a, b) do |wire_index|
      partner_index = partner(half_width_log2, layer_index, wire_index)
      case wire_index <=> partner_index
      when -1
        visitor.visit_gate(Gate.comparator_between(wire_index, partner_index))
      when 0
        visitor.visit_gate(Gate.passthrough_at(wire_index))
      end
    end
  end

  private def partner(half_width_log2, layer_index, wire_index)
    if Distance.new(0) == layer_index
      wire_index ^ (Distance.new(1) << half_width_log2)
    else
      r = half_width_log2 - layer_index
      s = wire_index >> r

      if {Distance.new(0), (Distance.new(1) << (layer_index + 1)) - 1}.includes? s
        wire_index # No comparator for this wire at this level.
      else
        wire_index - (1 - 2 * (s % 2)) * (1 << r)
      end
    end
  end
end
