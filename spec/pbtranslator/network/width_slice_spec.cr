require "../../spec_helper"

include SpecHelper

network_count = 10

oe_scheme =
  Scheme::OffsetResolution.new(
    Scheme::MergeSort::Recursive.new(
      Scheme::OddEvenMerge::INSTANCE
    )
  )

direct_scheme =
  Scheme::OffsetResolution.new(
    Scheme::MergeSort::Recursive.new(
      Scheme::DirectMerge::INSTANCE
    )
  )

# Randomly partitions a range of numbers into three parts so that the middle
# one is nonempty. Returns the two points that separate the parts.
def partition_in_three(n, random)
  points = Array.new(2) { Distance.new(random.rand(n)) }
  points.sort!
  left, right = points
  {left, right + 1}
end

def for_some_networks_of_random_width(network_count, random, sub_scheme)
  random_width_array(network_count, random).each do |width|
    sub_width = Math.pw2ceil(width)
    sub_network = sub_scheme.network(Width.from_pw2(sub_width))
    left, right = partition_in_three(sub_width, random)
    network = Network::WidthSlice.new(sub_network, begin: left, end: right)
    yield network, right - left
  end
end

def test_limits_with_sub_scheme(sub_scheme, network_count)
  random = Random.new(SEED)
  for_some_networks_of_random_width(network_count, random, sub_scheme) do |network, width|
    visitor = WidthCheckingVisitor.new(width)
    network.host(visitor)
  end
end

def test_sorting_with_sub_scheme(sub_scheme, network_count, visitor_factory)
  random = Random.new(SEED)
  for_some_networks_of_random_width(network_count, random, sub_scheme) do |network, width|
    a = Array.new(width) { yield random }
    b = a.clone
    c = sort(a)
    visitor = visitor_factory.new(b)
    network.host(visitor)
    b.should eq(c)
  end
end

describe Network::WidthSlice do
  it "trims oe merge sorting networks to within limits" do
    test_limits_with_sub_scheme(oe_scheme, network_count)
  end

  it "trims direct merge sorting networks to within limits" do
    test_limits_with_sub_scheme(direct_scheme, network_count)
  end

  it "sorts with the help of oe merge sorting networks" do
    test_sorting_with_sub_scheme(oe_scheme, network_count, Visitor::ArraySwap, &.next_float)
  end

  it "sorts with the help of direct merge sorting networks" do
    test_sorting_with_sub_scheme(direct_scheme, network_count, Visitor::ArrayLogic, &.next_bool)
  end
end
