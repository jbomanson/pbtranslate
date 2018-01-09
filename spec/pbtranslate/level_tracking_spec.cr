require "./bidirectional_host_helper"
require "../../spec_helper"

include PBTranslate

GATES_WITH_OPTIONS = [
  {Gate.comparator_between(Distance.new(0), Distance.new(1)), {level: Distance.new(0)}},
  {Gate.comparator_between(Distance.new(2), Distance.new(3)), {level: Distance.new(0)}},
  {Gate.comparator_between(Distance.new(0), Distance.new(2)), {level: Distance.new(1)}},
  {Gate.comparator_between(Distance.new(1), Distance.new(3)), {level: Distance.new(1)}},
  {Gate.comparator_between(Distance.new(1), Distance.new(2)), {level: Distance.new(2)}},
]

NETWORK =
  Network
    .flexible_comparator(GATES_WITH_OPTIONS.map(&.first.wires))
    .to_network_with_gate_level

describe "Network#to_network_with_gate_level" do
  it "computes levels in a small example network correctly" do
    NETWORK.gates_with_options.to_a.should eq(GATES_WITH_OPTIONS)
  end

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    NETWORK
  }
end
