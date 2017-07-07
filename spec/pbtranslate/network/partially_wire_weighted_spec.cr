require "../../spec_helper"

include SpecHelper

network_count = 10
weight_range = 0..1000
value_range = 0..1
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
  include Visitor

  getter sum

  def initialize
    @sum = T.zero.as(T)
  end

  def visit_gate(*args, **options, output_weights) : Nil
    @sum += output_weights.sum
  end

  def visit_region(region) : Nil
    yield self
  end
end

class DynamicGateWeightCountingVisitor(T)
  include Visitor

  getter values
  getter sum

  def initialize(@values : Array(T))
    @sum = T.zero.as(T)
  end

  def visit_gate(gate, **options, output_weights) : Nil
    wires = gate.wires.to_a
    local_values =
      wires.map do |wire|
        @values[wire]
      end
    local_values.sort!
    wires.zip(local_values) do |wire, value|
      @values[wire] = value
    end
    local_values.zip(output_weights.to_a) do |value, weight|
      @sum += value * weight
    end
  end

  def visit_region(region) : Nil
    yield self
  end
end

class WireWeightCollectingVisitor(T)
  include Visitor

  getter grid

  def initialize(@values : Array(T))
    @counter = DynamicGateWeightCountingVisitor(T).new(values)
    @grid = Array(Array(T)).new(@values.size) { Array(T).new }
  end

  def visit_gate(gate, **options, output_weights) : Nil
    @counter.visit_gate(gate, **options, output_weights)
    gate.wires.each do |wire|
      @grid[wire] << @counter.values[wire]
    end
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
    nnn.host(v.going(way))
    a, b = {v, w}.map &.sum
    a.should eq(b)
  end
end

def dynamic_test(network_count, scheme, layer_cache_class, random, weight_range, value_range)
  random_width_array(network_count, random).each do |value|
    width = Width.from_value(value)
    x = Array.new(width.value) { random.rand(value_range) }
    v = DynamicGateWeightCountingVisitor.new(x)
    w = Array.new(width.value) { random.rand(weight_range) }
    ww = w.clone
    n = scheme.network(width)
    y = BitArray.new(n.network_depth.to_i)
    y.each_index { |i| y[i] = yield }
    nn = layer_cache_class.new(network: n, width: width)
    nnn = Network::PartiallyWireWeighted.new(network: nn, bit_array: y, weights: ww)
    nnn.host(v.going(FORWARD))
    a, b = {v, w.zip(x).map { |u, v| u * v }}.map &.sum
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

  it "preserves dynamic sums of weights placed on all layers when going forward" do
    random = Random.new(seed)
    dynamic_test(network_count, scheme, layer_cache_class, random, weight_range, value_range) { true }
  end

  it "preserves dynamic sums of weights placed on random layers when going forward" do
    random = Random.new(seed)
    dynamic_test(network_count, scheme, layer_cache_class, random, weight_range, value_range) { random.next_bool }
  end

  it "works as expected with a step of 2 on a sample network" do
    # Initial weights:
    # 3  +   0  +   0
    #    |      |
    # 4  +   0  |+  0  +  0
    #           ||     |
    # 1  +   0  +|  0  +  0
    #    |       |
    # 1  +   0   +  0
    w = [3, 4, 1, 1]
    ww = w.clone
    width = Width.from_value(Distance.new(w.size))
    y = BitArray.new(3)
    y.each_index { |i| y[i] = (i % 2) == 0 }
    n = scheme.network(width)
    n.network_depth.should eq(3)
    x = Array.new(width.value) { |i| i == index ? 1 : 0 }
    v = WireWeightCollectingVisitor.new(x)
    nn = layer_cache_class.new(network: n, width: width)
    nnn = Network::PartiallyWireWeighted.new(network: nn, bit_array: y, weights: ww)
    nnn.host(v.going(FORWARD))
    # Expected final weights:
    # 2  +   0  +   1
    #    |      |
    # 3  +   0  |+  1  +  0
    #           ||     |
    # 0  +   0  +|  1  +  0
    #    |       |
    # 0  +   0   +  1
    v.grid.should eq(
      [
        [2, 0, 1],
        [3, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1],
      ]
    )
  end
end
