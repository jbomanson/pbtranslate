require "../../spec_helper"

include PBTranslator

struct MyVisitor
  getter array

  @array = Array({UInt32, Int32} | {UInt32, Int32, Int32}).new

  def visit_gate(g, *args, depth) : Void
    @array << {depth} + g.wires
  end
end

describe DepthTracking do
  it "computes depths in a small example network correctly" do
    e = [{0, 0, 1}, {0, 2, 3}, {1, 0, 2}, {1, 1, 3}, {2, 1, 2}]
    a = e.map {|(d, i, j)| {i, j}}
    network = Network::IndexableComparator.new(a)
    width = network.width # => 4
    visitor = MyVisitor.new
    nn = DepthTracking::Network.new(network: network, width: width)
    nn.host(visitor, FORWARD)
    b = nn.computed_depth
    b.should eq(3)
    visitor.array.select {|t| t.size == 3}.should eq(e)
  end
end
