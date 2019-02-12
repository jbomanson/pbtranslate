require "../../spec_helper"

include PBTranslate

private struct DummyScheme
  include Scheme
  include Scheme::WithArguments(Nil)

  def network(unused : Nil) : Network
    Network.singleton("gate")
  end
end

private struct DummySchemeWithDepth
  include Scheme
  include Scheme::WithArguments(Nil)

  def network(unused : Nil) : Network
    Network.singleton("gate", level: Distance.new(0))
  end
end

# A scheme with a gate type that is the union of the gate types of networks
# of types *A* and *B*.
private record DummyUnionScheme(A, B), one : A, two : B do
  include Scheme
  include Scheme::WithArguments(Nil)

  def network(unused : Nil) : Network
    [@one, @two].first.network(nil)
  end
end

scheme = Scheme.partial_flexible_void

describe PBTranslate::Scheme::PartialFlexibleVoid do
  it "generates no networks with #network?" do
    scheme.network?.should be_nil
    scheme.network?(Width.from_value(Distance.new(0))).should be_nil
  end

  it "does not change an empty set of gate options in unions" do
    empty = CompileTimeSet.create
    dummy = DummyScheme.new
    dummy.gate_option_keys.should eq(empty)
    DummyUnionScheme.new(dummy, scheme).gate_option_keys.should eq(empty)
    DummyUnionScheme.new(scheme, dummy).gate_option_keys.should eq(empty)
  end

  it "does not change a singleton set of gate options in unions" do
    level = CompileTimeSet.create(:level)
    dummy = DummySchemeWithDepth.new
    dummy.gate_option_keys.should eq(level)
    DummyUnionScheme.new(dummy, scheme).gate_option_keys.should eq(level)
    DummyUnionScheme.new(scheme, dummy).gate_option_keys.should eq(level)
  end
end
