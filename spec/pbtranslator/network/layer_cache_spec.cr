require "../../spec_helper"

include PBTranslator
include Gate::Restriction

scheme =
  DepthTracking::Scheme.new(
    Scheme::MergeSort::Recursive.new(
      Scheme::OEMerge::INSTANCE
    )
  )

cache_class =
  Network::LayerCache.class_for(
    Gate.comparator_between(0, 0),
    depth: 0_u32)

class WirePairCollector
  def initialize
    @wire_pairs = Array({Int32, Int32}).new
  end

  def visit_gate(g : Gate(_, _, {Int32, Int32}), way, *args, **options) : Void
    @wire_pairs << g.wires
  end

  def visit_gate(*args, **options) : Void
  end

  def visit_region(*args, **options) : Void
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
    (1..WIDTH_LOG2_MAX - 1).each do |width_log2|
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
    end
  end
end
