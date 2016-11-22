require "../../spec_helper"

include PBTranslator

scheme =
  Scheme::MergeSort::Recursive.new(
    Scheme::OEMerge::INSTANCE
  )

struct Network
  include Gate::Restriction
  def initialize(@wire_pairs : Array(Tuple(Int32, Int32)))
  end

  def width
    @wire_pairs.map(&.max).max + 1
  end

  def host(visitor, *args) : Void
    @wire_pairs.each do |pair|
      visitor.visit(Gate.comparator_between(*pair), *args)
    end
  end
end

struct MyVisitor
  getter array

  @array = Array({UInt32, Int32} | {UInt32, Int32, Int32}).new

  def visit(gate, *args, depth)
    @array << {depth} + gate.wires
  end
end

describe Visitor::ArrayDepth do
  it "computes depths in a small example network correctly" do
    e = [{0, 0, 1}, {0, 2, 3}, {1, 0, 2}, {1, 1, 3}, {2, 1, 2}]
    a = e.map {|(d, i, j)| {i, j}}
    network = Network.new(a)
    width = network.width # => 4
    visitor = MyVisitor.new
    wrapper = Visitor::ArrayDepth.new(width: width, visitor: visitor)
    network.host(wrapper, FORWARD)
    wrapper.depth.should eq(3)
    visitor.array.select {|t| t.size == 3}.should eq(e)
  end
end
