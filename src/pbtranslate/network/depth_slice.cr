require "../../util/restrict"

struct PBTranslate::Network::DepthSlice(N)
  delegate network_width, to: @network

  def initialize(*, @network : N, @range : Range(Distance, Distance))
  end

  # Returns an upper bound on the depth of this network.
  def network_depth : Distance
    {@network.network_depth, Distance.new(@range.size)}.min
  end

  # Returns an upper bound on the number of writes done by this network.
  def network_write_count : Area
    {@network.network_write_count, Area.new(network_depth) * network_width}.min
  end

  def host(visitor v) : Nil
    vv = Guide.new(v, @range)
    @network.host(vv)
  end

  private struct Guide(V)
    include Visitor

    delegate way, to: @visitor

    def initialize(@visitor : V, @range : Range(Distance, Distance))
    end

    def visit_gate(*args, **options, depth) : Nil
      (@range.includes? depth) && @visitor.visit_gate(*args, **options, depth: depth)
    end

    def visit_region(region) : Nil
      @visitor.visit_region(region) do |region_visitor|
        yield Guide.new(region_visitor, @range)
      end
    end
  end
end
