require "../../bidirectional_host_helper"
require "../../spec_helper"

include SpecHelper

private SEED          = SpecHelper.file_specific_seed
private NETWORK_COUNT = 10

oe_scheme =
  Scheme.pw2_merge_odd_even
        .to_scheme_pw2_divide_and_conquer
        .to_scheme_with_offset_resolution

direct_scheme =
  Scheme.pw2_merge_direct
        .to_scheme_pw2_divide_and_conquer
        .to_scheme_with_offset_resolution

# Randomly partitions a range of numbers into three parts so that the middle
# one is nonempty. Returns the two points that separate the parts.
private def partition_in_three(n, random)
  points = Array.new(2) { Distance.new(random.rand(n)) }
  points.sort!
  left, right = points
  {left, right + 1}
end

private def network_with_random_split(random, sub_scheme, width)
  sub_width = Math.pw2ceil(width)
  sub_network = sub_scheme.network(Width.from_pw2(sub_width))
  left, right = partition_in_three(sub_width, random)
  network = Network::WidthSlice.new(sub_network, begin: left, end: right)
  {network, right - left}
end

private def for_some_networks_of_random_width(random, sub_scheme)
  array_of_random_width(NETWORK_COUNT, random, min: 1).each do |width|
    yield network_with_random_split(random, sub_scheme, width)
  end
end

private def test_limits_with_sub_scheme(sub_scheme)
  random = Random.new(SEED)
  for_some_networks_of_random_width(random, sub_scheme) do |network, width|
    visitor = WidthCheckingVisitor.new(width)
    network.host(visitor)
  end
end

private def test_sorting_with_sub_scheme(sub_scheme, visitor_factory)
  random = Random.new(SEED)
  for_some_networks_of_random_width(random, sub_scheme) do |network, width|
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
    test_limits_with_sub_scheme(oe_scheme)
  end

  it "trims direct merge sorting networks to within limits" do
    test_limits_with_sub_scheme(direct_scheme)
  end

  it "sorts with the help of oe merge sorting networks" do
    test_sorting_with_sub_scheme(oe_scheme, Visitor::ArraySwap, &.next_float)
  end

  it "sorts with the help of direct merge sorting networks" do
    test_sorting_with_sub_scheme(direct_scheme, Visitor::ArrayLogic, &.next_bool)
  end

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    network_with_random_split(
      Random.new(SEED),
      oe_scheme,
      Distance.new(15),
    ).first
  }
end
