require "../../spec_helper"

# TODO: Enumerate different values of N.

N = 2

scheme = PBTranslator::Scheme::DirectMerge::INSTANCE

describe typeof(scheme) do
  it "represents a logic network that merges #{N}^2 booleans" do
    # Generate all sorted arrays of N booleans.
    x =
      Array.new(N + 1) do |i|
        Array.new(N) do |j|
          i <= j
        end
      end
    # Enumerate pairs of sorted pairs.
    x.product(x) do |u, v|
      a = u + v
      b = a.clone
      c = a.sort_by {|w| w ? 1 : 0}
      visitor = PBTranslator::Visitor::ArrayLogic.new(b, false)
      scheme.network(1).visit(visitor)
    end
  end
end
