require "../../spec_helper"

half_width_log2_max = 3
half_width_max = 1 << half_width_log2_max

scheme = PBTranslator::Scheme::DirectMerge::INSTANCE

describe typeof(scheme) do
  it "represents a network that merges up to #{half_width_max}^2 booleans" do
    (0..half_width_log2_max).each do |half_width_log2|
      half_width = 1 << half_width_log2
      # Generate all sorted arrays of N booleans.
      x =
        Array.new(half_width + 1) do |i|
          Array.new(half_width) do |j|
            j < i
          end
        end
      # Enumerate pairs of sorted pairs.
      x.product(x) do |u, v|
        a = u + v
        b = a.clone
        c = a.sort_by {|w| w ? 0 : 1}
        visitor = PBTranslator::Visitor::ArrayLogic.new(b, false)
        scheme.network(half_width_log2).visit(visitor)
        b.should eq(c)
      end
    end
  end
end
