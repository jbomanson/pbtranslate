require "../../spec_helper"

include PBTranslate

half_width_log2_max = Distance.new(3)
half_width_max = 1 << half_width_log2_max

scheme = Scheme::DirectPw2Merge::INSTANCE

describe typeof(scheme) do
  it "represents a network that merges up to #{half_width_max}^2 booleans" do
    (Distance.new(0)..half_width_log2_max).each do |half_width_log2|
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
        c = a.sort_by { |w| w ? 0 : 1 }
        visitor = Visitor::ArrayLogic.new(b)
        scheme.network(Width.from_log2(half_width_log2)).host(visitor)
        b.should eq(c)
      end
    end
  end
end
