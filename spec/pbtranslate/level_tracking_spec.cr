require "./bidirectional_host_helper"
require "../../spec_helper"

include PBTranslate

private module Private
  GATES_WITH_OPTIONS = [
    {Gate.comparator_between(Distance.new(0), Distance.new(1)), {level: Distance.new(0)}},
    {Gate.comparator_between(Distance.new(2), Distance.new(3)), {level: Distance.new(0)}},
    {Gate.comparator_between(Distance.new(0), Distance.new(2)), {level: Distance.new(1)}},
    {Gate.comparator_between(Distance.new(1), Distance.new(3)), {level: Distance.new(1)}},
    {Gate.comparator_between(Distance.new(1), Distance.new(2)), {level: Distance.new(2)}},
  ]

  NETWORK =
    Network
      .flexible_comparator(Private::GATES_WITH_OPTIONS.map(&.first.wires))
      .to_network_with_gate_level
end

describe "Network#to_network_with_gate_level" do
  it "computes levels in a small example network correctly" do
    Private::NETWORK.gates_with_options.to_a.should eq(Private::GATES_WITH_OPTIONS)
  end

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    Private::NETWORK
  }
end
