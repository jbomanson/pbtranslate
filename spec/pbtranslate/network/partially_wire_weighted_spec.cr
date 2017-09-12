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

# A visitor that accumulates the total sum of the *output_weights* fields of
# gates.
class GateWeightAccumulatingVisitor(T)
  include Visitor

  # The sum of all *output_weights* seen so far.
  getter sum : T

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

# A visitor for applying a comparator network to an array of values, and
# computing the weighted sum of the generated wire values and *output_weights*
# fields of the respective gates.
class WireWeightSumComputingVisitor(T)
  include Visitor

  # An array representing the current values of all wires.
  getter values : Array(T)

  # The weighted sum accumulated so far.
  getter sum : T

  # Create an insance based on given initial *values*.
  def initialize(@values : Array(T))
    @sum = T.zero.as(T)
  end

  def visit_gate(gate, **options, output_weights) : Nil
    wires = gate.wires.to_a
    # Sort the values of the _wires_ in place.
    local_values =
      wires.map do |wire|
        @values[wire]
      end
    local_values.sort!
    wires.zip(local_values) do |wire, value|
      @values[wire] = value
    end
    # Accumulate the dynamic sum.
    local_values.zip(output_weights.to_a) do |value, weight|
      @sum += value * weight
    end
  end

  def visit_region(region) : Nil
    yield self
  end
end

# A visitor for collecting the wire weights of a network into a two dimensional
# grid.
class WireWeightCollectingVisitor(T)
  include Visitor

  # A grid of wire weights.
  getter grid : Array(Array(T))

  def initialize(@values : Array(T))
    # A wire weight computer.
    # Only the wire weight computing capabilities of the visitor are used here
    # -- the sum computing aspect is not used.
    @computer = WireWeightSumComputingVisitor(T).new(values)
    @grid = Array(Array(T)).new(@values.size) { Array(T).new }
  end

  def visit_gate(gate, **options, output_weights) : Nil
    @computer.visit_gate(gate, **options, output_weights)
    gate.wires.each do |wire|
      @grid[wire] << @computer.values[wire]
    end
  end

  def visit_region(region) : Nil
    yield self
  end
end

# A rather useless test for checking that the sum of wire weights in a
# partially wire weighted network is the same as the sum of input weights.
def sum_test(network_count, scheme, layer_cache_class, random, weight_range, way)
  random_width_array(network_count, random).each do |value|
    width = Width.from_value(value)
    v = GateWeightAccumulatingVisitor(typeof(random.next_int)).new
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

weighted_sum_test( wire values andnetwork_count, scheme, layer_cache_class, random, weight_range, value_range)
  random_width_array(network_count, random).each do |value|
    width = Width.from_value(value)
    x = Array.new(width.value) { random.rand(value_range) }
    v = WireWeightSumComputingVisitor.new(x)
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
    sum_test(network_count, scheme, layer_cache_class, random, weight_range, FORWARD) { true }
  end

  it "preserves sums of weights placed on all layers when going backward" do
    random = Random.new(seed)
    sum_test(network_count, scheme, layer_cache_class, random, weight_range, BACKWARD) { true }
  end

  it "preserves sums of weights placed on random layers when going forward" do
    random = Random.new(seed)
    sum_test(network_count, scheme, layer_cache_class, random, weight_range, FORWARD) { random.next_bool }
  end

  it "preserves sums of weights placed on random layers when going backward" do
    random = Random.new(seed)
    sum_test(network_count, scheme, layer_cache_class, random, weight_range, BACKWARD) { random.next_bool }
  end

  it "preserves sums of wire values and weights placed on all layers when going forward" do
    random = Random.new(seed)
    weighted_sum_test(network_count, scheme, layer_cache_class, random, weight_range, value_range) { true }
  end

  it "preserves sums of wire values and weights placed on random layers when going forward" do
    random = Random.new(seed)
    weighted_sum_test(network_count, scheme, layer_cache_class, random, weight_range, value_range) { random.next_bool }
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
