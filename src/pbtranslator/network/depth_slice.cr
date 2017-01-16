require "../../util/restrict"

struct PBTranslator::Network::DepthSlice(N, I)
  include WithGateDepth::Network

  def initialize(*, @network : N, @width : I, @range : Range(I, I))
    Util.restrict(network, WithGateDepth::Network)
  end

  # Returns an upper bound on the size of this network.
  def size
    {@network.size, depth * @width}.min
  end

  # Returns an upper bound on the depth of this network.
  def depth
    {@network.depth, @range.size}.min
  end

  def host(visitor v, way y : Way) : Nil
    vv = Guide.new(v, @range)
    @network.host(vv, y)
  end

  private struct Guide(V, I)
    def initialize(@visitor : V, @range : Range(I, I))
    end

    def visit_gate(*args, **options, depth) : Nil
      (@range.includes? depth) && @visitor.visit_gate(*args, **options, depth: depth)
    end
  end
end
