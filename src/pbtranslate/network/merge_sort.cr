require "../scheme/merge_sort"
require "../scheme/odd_even_merge"

struct PBTranslate::Network::MergeSort(S, M)
  include FirstClass

  def initialize(@sort_scheme : S, @merge_scheme : M, @width : Width::Pw2)
    @width_log2 = width.log2.as(Distance)
  end

  private macro three_cases(zero, one_call, else_expr)
    less = Width.from_log2(@width_log2 - 1)
    case @width_log2
    when Distance.new(0)
      {{zero}}
    when Distance.new(1)
      @merge_scheme.network(less).{{one_call}}
    else
      {{else_expr}}
    end
  end

  {% for tuple in [{:network_write_count, :Area, 2}, {:network_read_count, :Area, 2}, {:network_depth, :Distance, 1}] %}
    def {{tuple[0].id}} : {{tuple[1].id}}
      three_cases(
        {{tuple[1].id}}.new(0),
        {{tuple[0].id}},
        @sort_scheme.network(less).{{tuple[0].id}} * {{tuple[2].id}} + @merge_scheme.network(less).{{tuple[0].id}},
      )
    end
  {% end %}

  def network_width : Distance
    Distance.new(1) << @width_log2
  end

  def host(visitor) : Nil
    host(visitor, visitor.way)
  end

  private def host(visitor, way : Forward)
    helper_host(visitor) do |less|
      pair_host(visitor, less)
      @merge_scheme.network(less).host(visitor)
    end
  end

  private def host(visitor, way : Backward)
    helper_host(visitor) do |less|
      @merge_scheme.network(less).host(visitor)
      pair_host(visitor, less)
    end
  end

  private def helper_host(*args) : Nil
    three_cases(nil, host(*args), yield less)
  end

  private def pair_host(visitor, less)
    sort_network = @sort_scheme.network(less)
    visitor.way.each_in({typeof(less.value).new(0), less.value}) do |amount|
      visitor.visit_region(Offset.new(amount)) do |region_visitor|
        sort_network.host(region_visitor)
      end
    end
  end
end
