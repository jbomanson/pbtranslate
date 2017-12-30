require "../../spec_helper"

include SpecHelper

private SEED = SpecHelper.file_specific_seed
network_count = 10
scheme = SpecHelper.pw2_sort_odd_even.to_scheme_flexible

private class WeightCountingVisitor(T)
  getter sum

  def initialize(@sum : T = T.zero)
  end

  def visit_weighted_wire(*args, weight, memo, **options)
    @sum += weight
    memo
  end
end

describe Network::WireWeighted do
  it "preserves sums of weights" do
    random = Random.new(SEED)
    array_of_random_width(network_count, random).each do |width|
      g = Visitor::Noop::INSTANCE
      w = WeightCountingVisitor(typeof(random.next_int)).new
      visitor = Visitor::GateAndWeightVisitorPair.new(gate_visitor: g, weight_visitor: w)
      weights = Array.new(width) { random.next_int }
      backup_weights = weights.clone
      n = scheme.network(Width.from_value(width))
      nn = Network::WireWeighted.new(network: n, weights: weights)
      nn.host(visitor)
      a, b = {w, backup_weights}.map &.sum
      a.should eq(b)
    end
  end
end
