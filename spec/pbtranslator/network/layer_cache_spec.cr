require "../../spec_helper"

include PBTranslator
include Gate::Restriction

scheme =
  DepthTracking::Scheme.new(
    Scheme::OffsetResolution.new(
      Scheme::MergeSort::Recursive.new(
        Scheme::OEMerge::INSTANCE
      )
    )
  )

cache_class =
  Network::LayerCache.class_for(
    Gate.comparator_between(Distance.zero, Distance.zero),
    depth: Distance.zero)

class WirePairCollector
  getter wire_count

  def initialize
    @wire_pairs = Array({Distance, Distance}).new
    @wire_count = 0
  end

  def visit_gate(g : Gate(_, _, {Distance, Distance}), *args, **options) : Nil
    @wire_pairs << g.wires
    @wire_count += g.wires.size
  end

  def visit_gate(g, *args, **options) : Nil
    @wire_count += g.wires.size
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
          x.host(y, FORWARD)
          y.consume_wire_pairs
        end
      p.size.should_not eq(0)
      q.should eq(p)
      vv.wire_count.should eq(n.network_depth * w.value)
    end
  end
end
