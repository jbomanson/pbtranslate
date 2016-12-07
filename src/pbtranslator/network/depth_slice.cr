struct PBTranslator::Network::DepthSlice(N, I)
  def initialize(*, @network : N, @width : I, @range : Range(I, I))
    check_network(network)
  end

  # Returns an upper bound on the size of this network.
  def size
    {@network.size, depth * @width}.min
  end

  # Returns an upper bound on the depth of this network.
  def depth
    {@network.depth, @range.size}.min
  end

  def host(visitor, *args, **options) : Void
    v = visitor
    vv = DepthSliceVisitor.new(v, @range)
    @network.host(vv, *args, **options)
  end

  private def check_network(network : WithDepth::Network)
  end

  private struct DepthSliceVisitor(V, I)
    def initialize(@visitor : V, @range : Range(I, I))
    end

    def visit(*args, **options, depth) : Void
      (@range.includes? depth) && @visitor.visit(*args, **options, depth: depth)
    end
  end
end