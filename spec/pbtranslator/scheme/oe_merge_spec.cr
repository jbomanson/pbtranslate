require "../../spec_helper"

scheme = PBTranslator::Scheme::OEMerge::INSTANCE

describe PBTranslator::Scheme::OEMerge do
  it "represents a network that merges 2 and 2 wires" do
    # Collect all sorted pairs of values in [0, ..., 3].
    x = Array.new(4, &.itself).permutations(2)
    x.each &.sort!
    x.uniq!
    # Enumerate pairs of sorted pairs.
    x.product(x) do |u, v|
      a = u + v
      b = a.clone
      c = a.sort
      visitor = PBTranslator::Visitor::ArraySwap.new(b)
      scheme.network(1).visit(visitor, PBTranslator::FORWARD)
      b.should eq(c)
    end
  end
end
