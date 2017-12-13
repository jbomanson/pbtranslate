require "../network"
require "../../util/restrict"

struct PBTranslate::Network::LevelSlice(N)
  include Network

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

  def host_reduce(visitor v, memo)
    vv = Guide.new(v, @range)
    memo = @network.host_reduce(vv, memo)
  end

  private struct Guide(V)
    include Visitor

    delegate way, to: @visitor

    def initialize(@visitor : V, @range : Range(Distance, Distance))
    end

    def visit_gate(gate, memo, level, **options)
      if @range.includes? level
        memo = @visitor.visit_gate(gate, memo, **options, level: level)
      end
      memo
    end

    def visit_region(region) : Nil
      @visitor.visit_region(region) do |region_visitor|
        yield Guide.new(region_visitor, @range)
      end
    end
  end
end
