require "../../spec_helper"

scheme = PBTranslator::Scheme::MergeSort::DEFAULT_INSTANCE

describe PBTranslator::Scheme::MergeSort do
  it "represents some networks that sort" do
    random = Random.new(SEED)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      a = Array.new(width) { random.rand }
      b = a.clone
      c = a.sort
      visitor = PBTranslator::Visitor::ArraySwap.new(b)
      scheme.network(width_log2).visit(visitor)
      b.should eq(c)
    end
  end

  it "returns consistent sizes" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(width_log2)
      a = network.size
      visitor = MethodCallCounter.new
      network.visit(visitor)
      b = visitor[:visit]
      a.should eq(b)
    end
  end

  it "represents matching numbers of gates going forward and backward" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(width_log2)
      a, x =
        begin
          visitor = MethodCallCounter.new
          network.visit(visitor)
          {visitor[:visit], visitor[:reverse_visit]}
        end
      b, y =
        begin
          visitor = MethodCallCounter.new
          network.reverse_visit(visitor)
          {visitor[:reverse_visit], visitor[:visit]}
        end
      x.should eq(0)
      y.should eq(0)
      a.should eq(b)
    end
  end

  it "returns consistent depths" do
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      network = scheme.network(width_log2)
      a = network.depth
      width = 1 << width_log2
      visitor = DepthCounter.new(width)
      network.visit(visitor)
      b = visitor.depth
      a.should eq(b)
    end
  end
end
