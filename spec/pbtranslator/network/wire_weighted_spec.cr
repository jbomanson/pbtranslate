require "../../spec_helper"

include SpecHelper

network_count = 10

scheme =
  Scheme::WidthLimited.new(
    Scheme::MergeSort::Recursive.new(
      Scheme::OEMerge::INSTANCE
    )
  )

class WeightCountingVisitor(T)
  getter sum

  def initialize(@sum : T = T.zero)
  end

  def visit(*args, **options, weight) : Void
    @sum += weight
  end
end

describe Network::WireWeighted do
  it "preserves sums of weights" do
    random = Random.new(SEED)
    random_width_array(network_count, random).each do |width|
      g = Visitor::Noop::INSTANCE
      w = WeightCountingVisitor(typeof(random.next_int)).new
      visitor = Network::WireWeighted.pair(gate_visitor: g, weight_visitor: w)
      weights = Array.new(width) { random.next_int }
      backup_weights = weights.clone
      n = scheme.network(Width.from_value(width))
      nn = Network::WireWeighted.new(network: n, weights: weights)
      nn.host(visitor, FORWARD)
      a, b = {w, backup_weights}.map &.sum
      a.should eq(b)
    end
  end
end
