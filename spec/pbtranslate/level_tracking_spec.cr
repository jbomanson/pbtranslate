require "../../spec_helper"

include PBTranslate

describe "Network#to_network_with_gate_level" do
  it "computes levels in a small example network correctly" do
    gates_with_options = [
      {Gate.comparator_between(Distance.new(0), Distance.new(1)), {level: Distance.new(0)}},
      {Gate.comparator_between(Distance.new(2), Distance.new(3)), {level: Distance.new(0)}},
      {Gate.comparator_between(Distance.new(0), Distance.new(2)), {level: Distance.new(1)}},
      {Gate.comparator_between(Distance.new(1), Distance.new(3)), {level: Distance.new(1)}},
      {Gate.comparator_between(Distance.new(1), Distance.new(2)), {level: Distance.new(2)}},
    ]
    Network
      .flexible_comparator(gates_with_options.map(&.first.wires))
      .to_network_with_gate_level
      .gates_with_options
      .to_a
      .should eq(gates_with_options)
  end
end
