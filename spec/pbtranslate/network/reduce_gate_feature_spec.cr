require "../../spec_helper"

include PBTranslate
include Gate::Restriction

describe "PBTranslate::Network#reduce_gate_feature" do
  it "computes gate wire counts classified by type" do
    hash = Hash(String, Distance).new(Distance.new(0))
    VarietyExampleNetwork
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
