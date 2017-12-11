require "../../spec_helper"

include PBTranslate

scheme = SpecHelper.pw2_sort_odd_even

describe Visitor::ArrayLogic do
  it "sorts booleans in descending order with merge sorting networks" do
    random = Random.new(SEED)
    (Distance.new(0)..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      a = Array.new(width) { random.next_bool }
      b = a.clone
      c = a.sort_by { |w| w ? 0 : 1 }
      visitor = Visitor::ArrayLogic.new(b)
      scheme.network(Width.from_log2(width_log2)).host(visitor)
      b.should eq(c)
    end
  end
end
