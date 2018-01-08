require "../../spec_helper"

include SpecHelper

private NETWORK_COUNT = 10
private WEIGHT_RANGE  = 0..1000
private VALUE_RANGE   = 0..1

private SCHEME =
  SpecHelper
    .pw2_sort_odd_even
    .to_scheme_flexible
    .to_scheme_with_gate_level
    .to_scheme_layer_cache

private SEED = SpecHelper.file_specific_seed

# A visitor that accumulates the total sum of the *output_weights* fields of
# gates.
private struct GateWeightAccumulatingVisitor
  include Visitor
  include Visitor::DefaultMethods

  def visit_gate(gate, memo, output_weights, **options)
    memo + output_weights.sum
  end
end

# A visitor for applying a comparator network to an array of values, and
# computing the weighted sum of the generated wire values and *output_weights*
# fields of the respective gates.
private struct WireWeightSumComputingVisitor
  include Visitor
  include Visitor::DefaultMethods

  def visit_gate(gate, memo, *, output_weights, **options)
    values, sum = memo
    wires = gate.wires.to_a
    # Sort the values of the _wires_ in place.
    local_values =
      wires.map do |wire|
        values[wire]
      end
    local_values.sort!
    wires.zip(local_values) do |wire, value|
      values[wire] = value
    end
    # Accumulate the dynamic sum.
    local_values.zip(output_weights.to_a) do |value, weight|
      sum += value * weight
    end
    {values, sum}
  end
end

# A visitor for collecting the wire weights of a network into a two dimensional
# grid.
private class WireWeightCollectingVisitor(T)
  include Visitor
  include Visitor::DefaultMethods

  # A grid of wire weights.
  getter grid : Array(Array(T))

  def initialize(size : Int)
    @grid = Array(Array(T)).new(size) { Array(T).new }
  end

  def visit_gate(gate, memo, *, output_weights, **options)
    gate.wires.zip(output_weights).each do |wire, weight|
      @grid[wire] << weight
    end
    memo
  end
end

private def abstract_test(random, bool_generator : -> Bool)
  array_of_random_width(NETWORK_COUNT, random).each do |value|
    width = Width.from_value(value)
    weights = Array.new(width.value) { random.rand(WEIGHT_RANGE) }
    weightless_network = SCHEME.network(width)
    bit_array = BitArray.new(weightless_network.network_depth.to_i)
    bit_array.each_index { |i| bit_array[i] = bool_generator.call }
    network =
      Network::PartiallyWireWeighted.new(
        network: weightless_network,
        bit_array: bit_array,
        weights: weights.clone,
      )
    yield network, weights
  end
end

# A rather useless test for checking that the sum of wire weights in a
# partially wire weighted network is the same as the sum of input weights.
private def sum_test(random, way, &block : -> Bool)
  abstract_test(random, block) do |network, weights|
    network.host_reduce(
      GateWeightAccumulatingVisitor.new.going(way),
      typeof(weights.first).zero,
    ).should eq(weights.sum)
  end
end

# A test for checking that the sum of wire weights weighted by wire values is
# the same as the sum of initial weights weighted by initial values.
# Both the wire weigths and wire values are based on random initial values.
private def weighted_sum_test(random, &block : -> Bool)
  abstract_test(random, block) do |network, weights|
    values = Array.new(weights.size) { random.rand(VALUE_RANGE) }
    network.host_reduce(
      WireWeightSumComputingVisitor.new.going(FORWARD),
      {values.clone, typeof(weights.first).zero},
    ).last
     .should eq(weights.zip(values).map { |u, v| u * v }.sum)
  end
end

private def weight_grid_test(comparators, depth, initial_weights, bit_array, expected_final_weights)
  n =
    Network::WrapperWithDepth.new(
      Network.flexible_comparator(comparators),
      network_depth: Distance.new(depth),
    )
  n.network_width.should eq(initial_weights.size)
  n = n.to_network_with_gate_level
  nn = Network::LayerCache.new(n, Width.from_value(n.network_width))
  nnnn = Network::PartiallyWireWeighted.new(network: nn, bit_array: bit_array, weights: initial_weights.clone)
  v = WireWeightCollectingVisitor(typeof(initial_weights.first)).new(nnnn.network_width)
  nnnn.host(v.going(FORWARD))
  v.grid.should eq(expected_final_weights)
  nnnn.network_depth.should eq(expected_final_weights.first.size)
  nnnn.gates_with_options.to_a.max_of(&.last[:level]).should eq(
    nnnn.network_depth - 1
  )
end

private def corner_case_weight_test_helper(random, width_value, bit_value, last_bit_value)
  width = Width.from_value(width_value)
  weights = Array.new(width_value) { random.rand(WEIGHT_RANGE) }
  visitor = WireWeightCollectingVisitor(typeof(weights.first)).new(width_value)
  n = SCHEME.network(width)
  bit_array = BitArray.new(n.network_depth.to_i, bit_value)
  unless bit_array.empty?
    bit_array[-1] = last_bit_value
  end
  nn = Network::PartiallyWireWeighted.new(network: n, bit_array: bit_array, weights: weights.clone)
  nn.host(visitor.going(FORWARD))
  {weights, visitor.grid}
end

describe Network::PartiallyWireWeighted do
  it "preserves sums of weights placed on all layers when going forward" do
    random = Random.new(SEED)
    sum_test(random, FORWARD) { true }
  end

  it "preserves sums of weights placed on all layers when going backward" do
    random = Random.new(SEED)
    sum_test(random, BACKWARD) { true }
  end

  it "preserves sums of weights placed on random layers when going forward" do
    random = Random.new(SEED)
    sum_test(random, FORWARD) { random.next_bool }
  end

  it "preserves sums of weights placed on random layers when going backward" do
    random = Random.new(SEED)
    sum_test(random, BACKWARD) { random.next_bool }
  end

  it "preserves sums of wire values and weights placed on all layers when going forward" do
    random = Random.new(SEED)
    weighted_sum_test(random) { true }
  end

  it "preserves sums of wire values and weights placed on random layers when going forward" do
    random = Random.new(SEED)
    weighted_sum_test(random) { random.next_bool }
  end

  it "works as expected with all layers on a sample 3-sorting network" do
    comparators = [{0, 1}, {0, 2}, {1, 2}]
    depth = 3
    initial_weights = [944, 354, 954]
    bit_array = BitArray.new(3, true)
    expected_final_weights = [
      [590, 0, 0, 354],
      [0, 0, 0, 354],
      [0, 600, 0, 354],
    ]
    weight_grid_test(comparators, depth, initial_weights, bit_array, expected_final_weights)
  end

  it "works as expected with a step of 2 and offset 0 on a sample 4-sorting network" do
    # Network with initial weights:
    # 3  +   0  +   0
    #    |      |
    # 4  +   0  |+  0  +  0
    #           ||     |
    # 1  +   0  +|  0  +  0
    #    |       |
    # 1  +   0   +  0
    comparators = [{0, 1}, {2, 3}, {0, 2}, {1, 3}, {1, 2}]
    depth = 3
    initial_weights = [3, 4, 1, 1]
    # Bit array and network with expected final weights:
    #        1      0     1
    # ---------------------
    # 0  +   2  +   0     1
    #    |      |
    # 1  +   2  |+  0  +  1
    #           ||     |
    # 0  +   0  +|  0  +  1
    #    |       |
    # 0  +   0   +  0     1
    bit_array = BitArray.new(3)
    bit_array.each_index { |i| bit_array[i] = (i % 2) == 0 }
    expected_final_weights = [
      [0, 2, 0, 1],
      [1, 2, 0, 1],
      [0, 0, 0, 1],
      [0, 0, 0, 1],
    ]
    weight_grid_test(comparators, depth, initial_weights, bit_array, expected_final_weights)
  end

  it "works as expected with a step of 2 and offset 1 on a sample 4-sorting network" do
    # Network with initial weights:
    # 3  +   0  +   0
    #    |      |
    # 4  +   0  |+  0  +  0
    #           ||     |
    # 1  +   0  +|  0  +  0
    #    |       |
    # 1  +   0   +  0
    comparators = [{0, 1}, {2, 3}, {0, 2}, {1, 3}, {1, 2}]
    depth = 3
    initial_weights = [3, 4, 1, 1]
    # Bit array and network with expected final weights:
    #        0      1     0
    # ---------------------
    # 2  +   0  +   1     0
    #    |      |
    # 3  +   0  |+  1  +  0
    #           ||     |
    # 1  +   0  +|  1  +  0
    #    |       |
    # 1  +   0   +  1     0
    bit_array = BitArray.new(3)
    bit_array.each_index { |i| bit_array[i] = (i % 2) == 1 }
    expected_final_weights = [
      [2, 0, 1, 0],
      [3, 0, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 1, 0],
    ]
    weight_grid_test(comparators, depth, initial_weights, bit_array, expected_final_weights)
  end

  it "propagates nothing when given a false bit array" do
    random = Random.new(SEED)
    array_of_random_width(NETWORK_COUNT, random).each do |width_value|
      weights, grid = corner_case_weight_test_helper(random, width_value, false, false)
      grid.map(&.first).should eq(weights)
      grid.each do |single_wire_weights|
        t = single_wire_weights[1..-1]
        t.should eq(t.map { 0 })
      end
    end
  end

  it "propagates in one step over everything when given a bit array with a single true bit at the end" do
    random = Random.new(SEED)
    array_of_random_width(NETWORK_COUNT, random, min: 1).each do |width_value|
      weights, grid = corner_case_weight_test_helper(random, width_value, false, true)
      least = weights.min
      if grid.size >= 2
        grid.map(&.first).should eq(weights.map &.-(least))
      end
      grid.map(&.last).should eq(weights.map { least })
      grid.each do |single_wire_weights|
        t = single_wire_weights[1..-2]
        t.should eq(t.map { 0 })
      end
    end
  end
end
