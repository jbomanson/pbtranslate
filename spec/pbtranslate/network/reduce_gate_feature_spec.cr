require "../../spec_helper"

include PBTranslate
include Gate::Restriction

private struct ExampleNetwork
  include Network

  def host_reduce(visitor, memo)
    wire_0 = Distance.new(0)
    wire_1 = Distance.new(1)
    wire_2 = Distance.new(2)
    memo = visitor.visit_gate(Gate.passthrough_at(wire_0), memo)
    memo = visitor.visit_gate(Gate.passthrough_at(wire_1), memo)
    memo = visitor.visit_gate(Gate.passthrough_at(wire_2), memo)
    memo = visitor.visit_gate(Gate.comparator_between(wire_0, wire_1), memo)
    memo = visitor.visit_gate(Gate.comparator_between(wire_1, wire_2), memo)
    memo = visitor.visit_gate(Gate.and_of(wire_1, wire_2), memo)
  end
end

describe "PBTranslate::Network#reduce_gate_feature" do
  it "computes gate wire counts classified by type" do
    hash = Hash(String, Distance).new(Distance.new(0))
    ExampleNetwork
      .new
      .reduce_gate_feature(nil) do |memo, wire_count, gate_function_name|
      hash[gate_function_name] += wire_count
      nil
    end
    hash.should eq({
      Passthrough.name => Distance.new(3*1),
      Comparator.name  => Distance.new(2*2),
      And.name         => Distance.new(1*2),
    })
  end
end
