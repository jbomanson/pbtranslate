require "../network"

struct PBTranslate::Network::Pw2DivideAndConquer(M, Q)
  include FirstClass
  include Network

  def initialize(@width : Width::Pw2, @combine_scheme : M, @conquer_scheme : Q)
    @width_log2 = width.log2.as(Distance)
  end

  private macro three_cases(zero, one_call, else_expr)
    less = Width.from_log2(@width_log2 - 1)
    case @width_log2
    when Distance.new(0)
      {{zero}}
    when Distance.new(1)
      @combine_scheme.network(less).{{one_call}}
    else
      {{else_expr}}
    end
  end

  {% for tuple in [{:network_write_count, :Area, 2}, {:network_read_count, :Area, 2}, {:network_depth, :Distance, 1}] %}
    def {{tuple[0].id}} : {{tuple[1].id}}
      three_cases(
        {{tuple[1].id}}.new(0),
        {{tuple[0].id}},
        @conquer_scheme.network(less).{{tuple[0].id}} * {{tuple[2].id}} + @combine_scheme.network(less).{{tuple[0].id}},
      )
    end
  {% end %}

  def network_width : Distance
    Distance.new(1) << @width_log2
  end

  def host_reduce(visitor, memo)
    host_reduce(visitor, memo, visitor.way)
  end

  private def host_reduce(visitor, memo, way : Forward)
    helper_host_reduce(visitor, memo) do |less|
      memo = pair_host_reduce(visitor, memo, less)
      memo = @combine_scheme.network(less).host_reduce(visitor, memo)
    end
  end

  private def host_reduce(visitor, memo, way : Backward)
    helper_host_reduce(visitor, memo) do |less|
      memo = @combine_scheme.network(less).host_reduce(visitor, memo)
      memo = pair_host_reduce(visitor, memo, less)
    end
  end

  private def helper_host_reduce(visitor, memo)
    three_cases(memo, host_reduce(visitor, memo), yield less)
  end

  private def pair_host_reduce(visitor, memo, less)
    conquer_network = @conquer_scheme.network(less)
    visitor.way.each_in({typeof(less.value).new(0), less.value}) do |amount|
      visitor.visit_region(Offset.new(amount)) do |region_visitor|
        memo = conquer_network.host_reduce(region_visitor, memo)
      end
    end
    memo
  end
end
