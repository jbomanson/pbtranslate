require "../../spec_helper"

wire_pairs_with_levels =
  [{0, 1, 0}, {0, 2, 1}, {1, 2, 2}].map &.map { |wire| Distance.new(wire) }

wire_pairs = wire_pairs_with_levels.map { |i, j, level| {i, j} }

describe "PBTranslate::Network#gates_with_options" do
  it "returns correct comparators" do
    expected_comparators =
      wire_pairs.map { |i, j| {Gate.comparator_between(i, j), NamedTuple.new} }
    network = Network.flexible_comparator(wire_pairs)
    network.gates_with_options.to_a.should eq(expected_comparators)
  end

  it "returns correct comparators with levels" do
    expected_comparators =
      wire_pairs_with_levels.map do |i, j, level|
        {Gate.comparator_between(i, j), NamedTuple.new(level: level)}
      end
    network = Network.flexible_comparator(wire_pairs).to_network_with_gate_level
    network.gates_with_options.to_a.should eq(expected_comparators)
  end
end
