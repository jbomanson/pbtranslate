require "../../spec_helper"

include PBTranslate

private struct DummyScheme
  include Scheme

  declare_gate_options
end

private struct DummySchemeWithDepth
  include Scheme

  declare_gate_options depth
end

private record DummyUnionScheme(A, B), one : A, two : B do
  delegate gate_options, to: (true ? @one : @two)
end

scheme = Scheme.partial_flexible_void

describe PBTranslate::Scheme::PartialFlexibleVoid do
  it "generates no networks with #network?" do
    scheme.network?.should be_nil
    scheme.network?(Width.from_value(Distance.new(0))).should be_nil
  end

  it "raises on #gate_options" do
    expect_raises(ImpossibleError) { scheme.gate_options }
  end

  it "does not change an empty set of #gate_options in unions" do
    empty = {depth: nil, output_cone: nil}
    dummy = DummyScheme.new
    dummy.gate_options.restrict(**empty)
    typeof(DummyUnionScheme.new(dummy, scheme).gate_options.restrict(**empty))
    typeof(DummyUnionScheme.new(scheme, dummy).gate_options.restrict(**empty))
  end
end
