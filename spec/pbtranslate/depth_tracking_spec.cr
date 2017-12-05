require "../../spec_helper"

include PBTranslate

struct MyVisitor
  include Visitor

  getter array

  @array = Array({Distance, Distance} | {Distance, Distance, Distance}).new

  def visit_gate(g, *args, depth) : Nil
    @array << {depth} + g.wires
  end
end

describe DepthTracking do
  it "computes depths in a small example network correctly" do
    e = [{0, 0, 1}, {0, 2, 3}, {1, 0, 2}, {1, 1, 3}, {2, 1, 2}]
    e = e.map &.map { |v| Distance.new(v) }
    a = e.map { |(d, i, j)| {i, j} }
    network = Network::FlexibleIndexableComparator.new(a)
    width = network.network_width # => 4
    visitor = MyVisitor.new
    nn = DepthTracking::Network.new(network: network, width: width)
    nn.host(visitor)
    visitor.array.select { |t| t.size == 3 }.should eq(e)
  end
end
