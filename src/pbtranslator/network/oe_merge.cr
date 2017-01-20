require "../gate"

# See `Scheme::OEMerge`.
class PBTranslator::Network::OEMerge
  # The binary logarithm of the width of the input halves of this network.
  getter half_width_log2

  # See `Scheme::OEMerge#network`.
  def initialize(@half_width_log2 : Distance)
  end

  # Returns the number of comparators in the network.
  def size
    (Distance.new(1) << half_width_log2) * half_width_log2 + 1
  end

  # Returns the number of comparators on the longest path from an input to
  # an output.
  def depth
    half_width_log2 + 1
  end

  # Hosts a visit over the comparators in this network placed at an
  # *offset*.
  #
  # The visit_gate method of *visitor* is called for each comparator.
  def host(visitor, way : Way, at offset = Distance.new(0)) : Nil
    a, b = {Distance.new(0), half_width_log2}
    way.each_between(a, b) do |layer_index|
      layer_host(visitor, way, offset, layer_index)
    end
  end

  private def layer_host(visitor, way, at offset, layer_index)
    a, b = {Distance.new(0), (Distance.new(1) << (half_width_log2 + 1)) - 1}
    way.each_between(a, b) do |wire_index|
      partner_index = partner(half_width_log2, layer_index, wire_index)
      case wire_index <=> partner_index
      when -1
        g =
          Gate
          .comparator_between(wire_index, partner_index)
          .shifted_by(offset)
        visitor.visit_gate(g)
      when 0
        g =
          Gate
          .passthrough_at(wire_index)
          .shifted_by(offset)
        visitor.visit_gate(g)
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
