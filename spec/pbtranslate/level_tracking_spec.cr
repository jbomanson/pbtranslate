require "../../spec_helper"

include PBTranslate

private struct MyVisitor
  include Visitor

  getter array

  @array = Array({Distance, Distance} | {Distance, Distance, Distance}).new

  def visit_gate(gate, memo, level)
    @array << {level} + gate.wires
    memo
  end
end

describe "Network#to_network_with_gate_level" do
  it "computes levels in a small example network correctly" do
    e = [{0, 0, 1}, {0, 2, 3}, {1, 0, 2}, {1, 1, 3}, {2, 1, 2}]
    e = e.map &.map { |v| Distance.new(v) }
    a = e.map { |(d, i, j)| {i, j} }
    network = Network.flexible_comparator(a).to_network_with_gate_level
    visitor = MyVisitor.new
    network.host(visitor)
    visitor.array.select { |t| t.size == 3 }.should eq(e)
  end
end
