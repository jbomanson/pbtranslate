require "../../spec_helper"

scheme =
  PBTranslator::Scheme::MergeSort::Recursive.new(
    PBTranslator::Scheme::OEMerge::INSTANCE
  )

describe PBTranslator::Scheme::MergeSort do
  it "represents some networks that sort" do
    random = Random.new(SEED)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      a = Array.new(width) { random.rand }
      b = a.clone
      c = a.sort
      visitor = PBTranslator::Visitor::ArraySwap.new(b)
      scheme.network(width_log2).visit(visitor, PBTranslator::FORWARD)
      b.should eq(c)
    end
  end

  it "returns consistent sizes" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(width_log2)
      a = network.size
      visitor = VisitCallCounter.new
      network.visit(visitor, PBTranslator::FORWARD)
      b = visitor.count(PBTranslator::FORWARD)
      a.should eq(b)
    end
  end

  it "represents matching numbers of gates going forward and backward" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(width_log2)

      vf, vb = Array.new(2) { VisitCallCounter.new }
      wf, wb = {PBTranslator::FORWARD, PBTranslator::BACKWARD}
      
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
      network.visit(visitor, PBTranslator::FORWARD)
      b = visitor.depth
      a.should eq(b)
    end
  end
end
