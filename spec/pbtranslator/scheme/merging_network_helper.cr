require "../../../spec_helper"

include SpecHelper

macro it_merges(l, r, visitor_call, network_call)
  l = {{l}}
  r = {{r}}
  it "represents a network that merges #{l} + #{r} wires" do
    # Prepare two sorted arrays of booleans.
    x, y = {l, r}.map { |t| Array.new(t + 1) { |c| Array.new(t, &.<(c)) } }
    # Enumerate pairs of sorted arrays of booleans.
    x.product(y) do |u, v|
      a = u + v
      b = a.clone
      c = sort(a)
      visitor = {{visitor_call}}(b)
      {{network_call}}(l, r).host(visitor, FORWARD)
      b.should eq(c)
    end
  end
end
