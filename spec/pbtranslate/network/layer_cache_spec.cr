require "../../spec_helper"

include PBTranslate
include Gate::Restriction

scheme = SpecHelper.pw2_sort_odd_even.to_scheme_with_gate_level

cache_class =
  Network::LayerCache.class_for(
    Gate.comparator_between(Distance.zero, Distance.zero),
    level: Distance.zero)

class WirePairCollector
  include Visitor

  getter wire_count

  def initialize
    @wire_pairs = Array({Distance, Distance}).new
    @wire_count = 0
  end

  def visit_gate(g : Gate(_, _, {Distance, Distance}), memo, *args, **options)
    @wire_pairs << g.wires
    @wire_count += g.wires.size
    memo
  end

  def visit_gate(g, memo, *args, **options)
    @wire_count += g.wires.size
    memo
  end

  def visit_region(region) : Nil
    yield self
  end

  def consume_wire_pairs
    w = @wire_pairs
    w.sort!
    w
  end
end

describe Network::LayerCache do
  it "preserves the comparators of sample merge sort networks" do
    (Distance.new(1)..WIDTH_LOG2_MAX - 1).each do |width_log2|
      w = Width.from_log2(width_log2)
      n = scheme.network(w)
      nn = cache_class.new(network: n, width: w)
      v, vv = {0, 0}.map { WirePairCollector.new }
      p, q =
        { {n, v}, {nn, vv} }.map do |(x, y)|
          x.host(y)
          y.consume_wire_pairs
        end
      p.size.should_not eq(0)
      q.should eq(p)
      vv.wire_count.should eq(n.network_depth * w.value)
    end
  end
end
