require "../../../spec_helper"

include SpecHelper

def it_merges(l, r, visitor_class, &network_proc : Int32, Int32 -> U) forall U
  it "represents a network that merges #{l} + #{r} wires" do
    # Prepare two sorted arrays of booleans.
    x, y = {l, r}.map { |t| Array.new(t + 1) { |c| Array.new(t, &.<(c)) } }
    # Enumerate pairs of sorted arrays of booleans.
    x.product(y) do |u, v|
      a = u + v
      b = a.clone
      c = sort(a)
      visitor = visitor_class.new(b)
      network_proc.call(l, r).host(visitor)
      b.should eq(c)
    end
  end
end
