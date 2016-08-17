require "../../spec_helper"

WIDTH_LOG2_MAX = 10

scheme = PBTranslator::Scheme::MergeSort::DEFAULT_INSTANCE

describe PBTranslator::Scheme::MergeSort do
  it "represents some networks that sort" do
    seed = 482382392
    random = Random.new(seed)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      a = Array.new(width) { random.rand }
      b = a.clone
      c = a.sort
      visitor = PBTranslator::Visitor::ArraySwap.new(b)
      scheme.visit(width_log2, 0, visitor)
      b.should eq(c)
    end
  end

  it "returns consistent sizes" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      a = scheme.size(width_log2)
      visitor = MethodCallCounter.new
      scheme.visit(width_log2, 0, visitor)
      b = visitor[:visit_comparator]
      a.should eq(b)
    end
  end
  
  it "returns consistent depths" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      a = scheme.depth(width_log2)
      width = 1 << width_log2
      visitor = DepthCounter.new(width)
      scheme.visit(width_log2, 0, visitor)
      b = visitor.depth
      a.should eq(b)
    end
  end
end
