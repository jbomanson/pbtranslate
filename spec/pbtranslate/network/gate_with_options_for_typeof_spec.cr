require "../../spec_helper"
require "../../eval_spec_helper_spec"

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

private NETWORK_WITH_AMBIGUOUS_OPTIONS = <<-EOF
  require "../src/pbtranslate/network"
  require "../src/pbtranslate/number_types"

  include PBTranslate

  private struct NetworkWithAmbiguousOptions
    include Network

    def host_reduce(visitor, memo)
      memo = visitor.visit_gate(1, memo, level: Distance.new(0))
      memo = visitor.visit_gate(1, memo)
      memo
    end
  end

  typeof(NetworkWithAmbiguousOptions.new.gate_with_options_for_typeof)
EOF

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

  it "catches ambiguous options at compile time" do
    output = SpecHelper.eval(NETWORK_WITH_AMBIGUOUS_OPTIONS)
    output.should match(/\QNetworkWithAmbiguousOptions\E/)
    output.should match(/\QNamedTuple() | NamedTuple(level: UInt32)\E/)
    output.should match(/\QExpected anything but a nilable union type, got\E/)
  end
end
