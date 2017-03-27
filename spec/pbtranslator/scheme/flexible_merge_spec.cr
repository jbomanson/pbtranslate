require "../../spec_helper"

include SpecHelper

scheme =
  Scheme::FlexibleMerge.new(
    Scheme::OEMerge::INSTANCE
  )

macro it_merges(l, r, visitor_factory)
  l = {{l}}
  r = {{r}}
  it "represents a network that merges #{l} + #{r} wires" do
    widths = {l, r}.map { |t| Width.from_value(Distance.new(t)) }
    # Prepare two sorted arrays of booleans.
    x, y = {l, r}.map { |t| Array.new(t + 1) { |c| Array.new(t, &.<(c)) } }
    # Enumerate pairs of sorted arrays of booleans.
    x.product(y) do |u, v|
      a = u + v
      b = a.clone
      c = sort(a)
      visitor = {{visitor_factory}}.new(b)
      scheme.network(widths).host(visitor, FORWARD)
      b.should eq(c)
    end
  end
end

describe Scheme::FlexibleMerge do
  {% begin %}
    {% a = [1, 2, 3, 4, 5] %}
    {% for l in a %}
      {% for r in a %}
        it_merges({{l}}, {{r}}, Visitor::ArrayLogic)
      {% end %}
    {% end %}
  {% end %}
end
