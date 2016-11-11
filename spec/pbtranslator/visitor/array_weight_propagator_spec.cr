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

  def visit(*args, **options, weight)
    @sum += weight
  end
end

describe Visitor::ArrayWeightPropagator do
  it "preserves sums of weights" do
    random = Random.new(SEED)
    random_width_array(network_count, random).each do |width|
      network = scheme.network(width)
      visitor = WeightCountingVisitor(typeof(random.next_int)).new
      weights = Array.new(width) { random.next_int }
      backup_weights = weights.clone
      Visitor::ArrayWeightPropagator.arrange_visit(
        FORWARD,
        network:        network,
        gate_visitor:   Visitor::Noop::INSTANCE,
        weight_visitor: visitor,
        weights:        weights)
      a, b = {visitor, backup_weights}.map &.sum
      a.should eq(b)
    end
  end
end
