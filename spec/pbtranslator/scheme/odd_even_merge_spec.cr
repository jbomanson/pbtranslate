require "../../spec_helper"

include PBTranslator

scheme = Scheme::OddEvenMerge::INSTANCE

describe Scheme::OddEvenMerge do
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
      visitor = Visitor::ArraySwap.new(b)
      scheme.network(Width.from_log2(Distance.new(1))).host(visitor, FORWARD)
      b.should eq(c)
    end
  end
end
