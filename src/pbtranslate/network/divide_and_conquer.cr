require "../not_implemented_error"

struct PBTranslate::Network::DivideAndConquer(P, R, E)
  {% for message in [:network_depth, :network_write_count] %}
    def {{message.id}} : NoReturn
      s = "Network::DivideAndConquer\#{{message.id}} is not implemented"
      raise NotImplementedError.new(s)
    end
  {% end %}

  def initialize(*, @widths : P, @conquer_scheme : R, @combine_scheme : E)
    Util.restrict(widths, Enumerable(Width))
  end

  def network_width : Distance
    @widths.last.value
  end

  def host(visitor) : Nil
    host(visitor, visitor.way)
  end

  private def host(visitor, way : Forward)
    divide_and_conquer(visitor)
    combine(visitor)
  end

  private def host(visitor, way : Backward)
    combine(visitor)
    divide_and_conquer(visitor)
  end

  private def divide_and_conquer(visitor)
    each_wire_slice(visitor.way) do |position, width|
      visitor.visit_region(Offset.new(position)) do |region_visitor|
        @conquer_scheme.network(width).host(region_visitor)
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

  private def combine(visitor)
    @combine_scheme.network(@widths).host(visitor)
  end
end
