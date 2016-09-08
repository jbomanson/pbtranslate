require "../../spec_helper"

scheme =
  PBTranslator::Scheme::MergeSort::Recursive.new(
    PBTranslator::Scheme::OEMerge::INSTANCE
  )

describe PBTranslator::Visitor::ArrayLogic do
  it "sorts booleans with merge sorting networks" do
    random = Random.new(SEED)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      a = Array.new(width) { random.next_bool }
      b = a.clone
      c = a.sort_by {|w| w ? 1 : 0}
      visitor = PBTranslator::Visitor::ArrayLogic.new(b, false)
      scheme.network(width_log2).visit(visitor)
      b.should eq(c)
    end
  end
end