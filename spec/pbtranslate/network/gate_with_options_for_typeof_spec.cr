require "../../spec_helper"

private struct NetworkOfInt32
  include Network

  def host_reduce(visitor, memo)
    memo = visitor.visit_gate(1, memo)
    memo = visitor.visit_gate(2, memo)
    memo
  end
end

private struct NetworkOfInt32AndString
  include Network

  def host_reduce(visitor, memo)
    memo = visitor.visit_gate(1, memo)
    memo = visitor.visit_gate("a", memo)
    memo
  end
end

describe "PBTranslate::Network#gate_with_options_for_typeof" do
  it "gives the right type of gates for a network of Int32 values" do
    typeof(NetworkOfInt32.new.gate_with_options_for_typeof).should eq(
      Tuple(Int32, typeof(NamedTuple.new))
    )
  end

  it "gives the right type of gates for a network of Int32 and String values" do
    typeof(NetworkOfInt32AndString.new.gate_with_options_for_typeof).should eq(
      Tuple(Int32 | String, typeof(NamedTuple.new))
    )
  end
end
