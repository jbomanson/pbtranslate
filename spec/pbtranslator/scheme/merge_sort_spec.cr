require "../../spec_helper"

include PBTranslator
include Gate::Restriction

scheme =
  Scheme::MergeSort::Recursive.new(
    Scheme::OEMerge::INSTANCE
  )

describe Scheme::MergeSort do
  it "represents some networks that sort" do
    random = Random.new(SEED)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      a = Array.new(width) { random.rand }
      b = a.clone
      c = a.sort
      visitor = Visitor::ArraySwap.new(b)
      scheme.network(Width.from_log2(width_log2)).host(visitor, FORWARD)
      b.should eq(c)
    end
  end

  it "returns consistent sizes" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(Width.from_log2(width_log2))
      a = network.size
      visitor = VisitCallCounter.new
      network.host(visitor, FORWARD)
      b = visitor.count(Comparator, InPlace)
      a.should eq(b)
    end
  end

  it "represents matching numbers of gates going forward and backward" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(Width.from_log2(width_log2))

      vf, vb = Array.new(2) { VisitCallCounter.new }
      wf, wb = {FORWARD, BACKWARD}
      
      network.host(vf, wf)
      network.host(vb, wb)

      ff = vf.count(Comparator, InPlace)
      bb = vb.count(Comparator, InPlace)

      ff.should eq(bb)
    end
  end

  it "returns consistent depths" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(Width.from_log2(width_log2))
      a = network.depth
      width = 1 << width_log2
      visitor = PBTranslator::Visitor::Noop::INSTANCE
      nn = DepthTracking::Network.new(network: network, width: width)
      nn.host(visitor, FORWARD)
      b = nn.computed_depth
      a.should eq(b)
    end
  end
end
