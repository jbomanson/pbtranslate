struct PBTranslator::Network::DivideAndConquer(P, R, E)
  def initialize(*, @widths : P, @conquer_scheme : R, @combine_scheme : E)
    Util.restrict(widths, Enumerable(Width))
  end

  def network_width : Distance
    @widths.last.value
  end

  def host(visitor, way : Forward) : Nil
    divide_and_conquer(visitor, way)
    combine(visitor, way)
  end

  def host(visitor, way : Backward) : Nil
    combine(visitor, way)
    divide_and_conquer(visitor, way)
  end

  private def divide_and_conquer(visitor, way)
    each_wire_slice(way) do |position, width|
      visitor.visit_region(Offset.new(position)) do |region_visitor|
        @conquer_scheme.network(width).host(region_visitor, way)
      end
    end
  end

  private def each_wire_slice(way)
    position = way.first(Distance.new(0), network_width)
    way.each_in(@widths) do |width|
      yield position, width
      position += way.sign * width.value
    end
  end

  private def combine(visitor, way)
    @combine_scheme.network(@widths).host(visitor, way)
  end
end
