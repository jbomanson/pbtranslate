require "../scheme/merge_sort"
require "../scheme/oe_merge"

struct PBTranslator::Network::MergeSort(S, M)
  include FirstClass

  def initialize(@sort_scheme : S, @merge_scheme : M, @width_log2 : Distance)
  end

  private macro three_cases(zero, one_call, else_expr)
    less_value = @width_log2 - 1
    less = Width.from_log2(less_value)
    case @width_log2
    when Distance.new(0)
      {{zero}}
    when Distance.new(1)
      @merge_scheme.network(less).{{one_call}}
    else
      {{else_expr}}
    end
  end

  {% for count in [:network_write_count, :network_read_count] %}
    def {{count.id}} : Area
      three_cases(
        Area.new(0),
        {{count.id}},
        @sort_scheme.network(less).{{count.id}} * 2 + @merge_scheme.network(less).{{count.id}},
      )
    end
  {% end %}

  def network_depth : Distance
    three_cases(
      Distance.new(0),
      network_depth,
      @sort_scheme.network(less).network_depth + @merge_scheme.network(less).network_depth,
    )
  end

  def network_width : Distance
    Distance.new(1) << @width_log2
  end

  private def helper_host(*args) : Nil
    three_cases(
      nil,
      host(*args),
      yield less, Distance.new(1) << less_value, @sort_scheme.network(less)
    )
  end

  def host(visitor, way : Forward, at offset = Distance.new(0)) : Nil
    helper_host(visitor, way, offset) do |less, more, sort_network|
      sort_network.host(visitor, way, offset)
      sort_network.host(visitor, way, offset + more)
      @merge_scheme.network(less).host(visitor, way, offset)
    end
  end

  def host(visitor, way : Backward, at offset = Distance.new(0)) : Nil
    helper_host(visitor, way, offset) do |less, more, sort_network|
      @merge_scheme.network(less).host(visitor, way, offset)
      sort_network.host(visitor, way, offset + more)
      sort_network.host(visitor, way, offset)
    end
  end
end
