require "../../spec_helper"

include SpecHelper

network_count = 10
weight_range = 0..1000
seed = SEED ^ __FILE__.hash

scheme =
  DepthTracking::Scheme.new(
    Scheme::WidthLimited.new(
      Scheme::OffsetResolution.new(
        Scheme::MergeSort::Recursive.new(
          Scheme::OddEvenMerge::INSTANCE
        )
      )
    )
  )

layer_cache_class =
  Network::LayerCache.class_for(
    Gate.comparator_between(Distance.zero, Distance.zero),
    depth: Distance.zero)

class GateWeightCountingVisitor(T)
  getter sum

  def initialize(@sum : T = T.zero)
  end

  def visit_gate(*args, **options, output_weights) : Nil
    @sum += output_weights.sum
  end

  def visit_region(region) : Nil
    yield self
  end
end

def test(network_count, scheme, layer_cache_class, random, weight_range, way)
  random_width_array(network_count, random).each do |value|
    width = Width.from_value(value)
    v = GateWeightCountingVisitor(typeof(random.next_int)).new
    w = Array.new(width.value) { random.rand(weight_range) }
    ww = w.clone
    n = scheme.network(width)
    y = BitArray.new(n.network_depth.to_i)
    y.each_index { |i| y[i] = yield }
    nn = layer_cache_class.new(network: n, width: width)
    nnn = Network::PartiallyWireWeighted.new(network: nn, bit_array: y, weights: ww)
    nnn.host(v, way)
    a, b = {v, w}.map &.sum
    a.should eq(b)
  end
end

describe Network::PartiallyWireWeighted do
  it "preserves sums of weights placed on all layers when going forward" do
    random = Random.new(seed)
    test(network_count, scheme, layer_cache_class, random, weight_range, FORWARD) { true }
  end

  it "preserves sums of weights placed on all layers when going backward" do
    random = Random.new(seed)
    test(network_count, scheme, layer_cache_class, random, weight_range, BACKWARD) { true }
  end

  it "preserves sums of weights placed on random layers when going forward" do
    random = Random.new(seed)
    test(network_count, scheme, layer_cache_class, random, weight_range, FORWARD) { random.next_bool }
  end

  it "preserves sums of weights placed on random layers when going backward" do
    random = Random.new(seed)
    test(network_count, scheme, layer_cache_class, random, weight_range, BACKWARD) { random.next_bool }
  end
end
