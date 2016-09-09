require "../../spec_helper"

L = 1
N = 1 << L

scheme = PBTranslator::Scheme::DirectMerge::INSTANCE

describe typeof(scheme) do
  it "represents a logic network that merges #{N}^2 booleans" do
    # Generate all sorted arrays of N booleans.
    x =
      Array.new(N + 1) do |i|
        Array.new(N) do |j|
          !(i <= j)
        end
      end
    # Enumerate pairs of sorted pairs.
    x.product(x) do |u, v|
      a = u + v
      b = a.clone
      c = a.sort_by {|w| w ? 0 : 1}
      visitor = PBTranslator::Visitor::ArrayLogic.new(b, false)
      scheme.network(L).visit(visitor)
      b.should eq(c)
    end
  end
end
