require "../../spec_helper"

include SpecHelper

network_count = 10

scheme =
  Scheme.pw2_merge_odd_even
        .to_scheme_pw2_divide_and_conquer
        .to_scheme_with_offset_resolution
        .to_scheme_flexible

class WeightCountingVisitor(T)
  getter sum

  def initialize(@sum : T = T.zero)
  end

  def visit_weighted_wire(*args, weight, **options) : Nil
    @sum += weight
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
