require "../network"
require "../not_implemented_error"

struct PBTranslate::Network::DivideAndConquer(P, R, E)
  include Network

  def network_depth : Distance
    @widths.max_of { |width| @conquer_scheme.network(width).network_depth } +
      @combine_scheme.network(@widths).network_depth
  end

  def network_write_count : Area
    @widths.sum { |width| @conquer_scheme.network(width).network_write_count }.as(Area) +
      @combine_scheme.network(@widths).network_write_count.as(Area)
  end

  def initialize(*, @widths : P, @conquer_scheme : R, @combine_scheme : E)
    Util.restrict(widths, Enumerable(Width))
  end

  def network_width : Distance
    @widths.last.value
  end

  def host_reduce(visitor, memo)
    host_reduce(visitor, memo, visitor.way)
  end

  private def host_reduce(visitor, memo, way : Forward)
    host_reduce_combine(visitor, host_reduce_divide_and_conquer(visitor, memo))
  end

  private def host_reduce(visitor, memo, way : Backward)
    host_reduce_divide_and_conquer(visitor, host_reduce_combine(visitor, memo))
  end

  private def host_reduce_divide_and_conquer(visitor, memo)
    each_wire_slice(visitor.way) do |position, width|
      visitor.visit_region(Offset.new(position)) do |region_visitor|
        memo = @conquer_scheme.network(width).host_reduce(region_visitor, memo)
      end
    end
    memo
  end

  private def host_reduce_combine(visitor, memo)
    @combine_scheme.network(@widths).host_reduce(visitor, memo)
  end

  private def each_wire_slice(way)
    position = way.first(Distance.new(0), network_width)
    way.each_in(@widths) do |width|
      yield position, width
      position += way.sign * width.value
    end
  end
end
