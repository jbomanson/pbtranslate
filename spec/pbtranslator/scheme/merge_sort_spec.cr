require "../../spec_helper"

include PBTranslator

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
      scheme.network(width_log2).visit(visitor, FORWARD)
      b.should eq(c)
    end
  end

  it "returns consistent sizes" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(width_log2)
      a = network.size
      visitor = VisitCallCounter.new
      network.visit(visitor, FORWARD)
      b = visitor.count(FORWARD)
      a.should eq(b)
    end
  end

  it "represents matching numbers of gates going forward and backward" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(width_log2)

      vf, vb = Array.new(2) { VisitCallCounter.new }
      wf, wb = {FORWARD, BACKWARD}
      
      network.visit(vf, wf)
      network.visit(vb, wb)

      ff, fb = {wf, wb}.map {|w| vf.count(w)}
      bf, bb = {wf, wb}.map {|w| vb.count(w)}

      fb.should eq(0)
      bf.should eq(0)
      (ff + fb).should eq(bf + bb)
      ff.should eq(bb)
    end
  end

  it "returns consistent depths" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(width_log2)
      a = network.depth
      width = 1 << width_log2
      visitor = DepthCounter.new(width)
      network.visit(visitor, FORWARD)
      b = visitor.depth
      a.should eq(b)
    end
  end
end
