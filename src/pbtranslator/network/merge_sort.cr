require "../scheme/merge_sort"
require "../scheme/oe_merge"

class PBTranslator::Network::MergeSort(S, M)
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

  def size
    three_cases(
      Distance.new(0),
      size,
      @sort_scheme.network(less).size * 2 + @merge_scheme.network(less).size,
    )
  end

  def depth
    three_cases(
      Distance.new(0),
      depth,
      @sort_scheme.network(less).depth + @merge_scheme.network(less).depth,
    )
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
