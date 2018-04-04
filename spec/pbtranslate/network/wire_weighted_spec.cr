require "../../spec_helper"

include SpecHelper

private SEED = SpecHelper.file_specific_seed
network_count = 10
scheme =
  SpecHelper
    .pw2_sort_odd_even
    .to_scheme_flexible
    .to_scheme_with_gate_level

private class WeightCountingVisitor(T)
  getter sum

  def initialize(@sum : T = T.zero)
  end

  def visit_weighted_wire(*args, weight, memo, **options)
    @sum += weight
    memo
  end
end

private def weight_grid_test(comparators, initial_weights, expected_weight_grid)
  network =
    Network::WrapperWithDepth.new(
      Network.flexible_comparator(comparators),
      network_depth: Distance.new(expected_weight_grid.first.size - 1),
    )
  network.network_width.should eq(initial_weights.size)
  network = network.to_network_with_gate_level
  layer_cache_network =
    Network::LayerCache.new(network, Width.from_value(network.network_width))
  wire_weighted_network =
    Network::WireWeighted.new(
      network: layer_cache_network,
      weights: initial_weights.clone,
    )

  wires_with_levels_and_weights =
    wire_weighted_network.gates_with_options.to_a.flat_map do |(gate, options)|
      gate.wires.zip(options[:input_weights]).map do |wire, weight|
        {wire, options[:level], weight}
      end
    end
  wires_with_levels =
    wires_with_levels_and_weights.map { |(wire, level, weight)| {wire, level} }
  wires_with_levels.uniq.should eq(wires_with_levels)

  actual_weight_grid = expected_weight_grid.map(&.map { -1 })
  wires_with_levels_and_weights.each do |wire, level, weight|
    wire.should be < actual_weight_grid.size
    level.should be < actual_weight_grid[wire].size
    actual_weight_grid[wire][level].should eq(-1)
    actual_weight_grid[wire][level] = weight
  end
  actual_weight_grid.each(&.map! { |weight| weight == -1 ? 0 : weight })
  actual_weight_grid.should eq(expected_weight_grid)

  wire_weighted_network.network_depth.should eq(expected_weight_grid.first.size)
  wire_weighted_network.gates_with_options.to_a.max_of(&.last[:level]).should eq(
    wire_weighted_network.network_depth - 1
  )
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

  it "works as expected on a sample 3-sorting network" do
    comparators = [{0, 1}, {0, 2}, {1, 2}]
    depth = 3
    initial_weights = [944, 354, 954]
    expected_weight_grid = [
      [590, 0, 0, 354],
      [0, 0, 0, 354],
      [0, 600, 0, 354],
    ]
    weight_grid_test(comparators, initial_weights, expected_weight_grid)
  end
end
