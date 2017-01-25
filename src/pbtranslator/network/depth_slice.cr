require "../../util/restrict"

struct PBTranslator::Network::DepthSlice(N)
  include WithGateDepth::Network

  def initialize(*, @network : N, @width : Distance, @range : Range(Distance, Distance))
    Util.restrict(network, WithGateDepth::Network)
  end

  # Returns an upper bound on the depth of this network.
  def network_depth : Distance
    {@network.network_depth, Distance.new(@range.size)}.min
  end

  def network_width : Distance
    @width
  end

  # Returns an upper bound on the number of writes done by this network.
  def network_write_count : Area
    {@network.network_write_count, Area.new(network_depth) * network_width}.min
  end

  def host(visitor v, way y : Way) : Nil
    vv = Guide.new(v, @range)
    @network.host(vv, y)
  end

  private struct Guide(V)
    def initialize(@visitor : V, @range : Range(Distance, Distance))
    end

    def visit_gate(*args, **options, depth) : Nil
      (@range.includes? depth) && @visitor.visit_gate(*args, **options, depth: depth)
    end
  end
end
