require "../../spec_helper"

include PBTranslate
include Gate::Restriction

describe PBTranslate::Network do
  it "#compute_gate_count computes gate counts" do
    VarietyExampleNetwork.new.compute_gate_count.should eq(Area.new(6))
  end

  it "#compute_gate_cost gate costs" do
    costs = {
      Passthrough.name => Area.new(1),
      Comparator.name  => Area.new(10),
      And.name         => Area.new(100),
    }
    VarietyExampleNetwork.new.compute_gate_cost(costs).should eq(Area.new(123))
  end
end
