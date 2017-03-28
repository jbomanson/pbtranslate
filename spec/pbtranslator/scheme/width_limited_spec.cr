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

def test_limits_with_sub_scheme(sub_scheme, network_count)
  scheme = Scheme::WidthLimited.new(sub_scheme)
  random = Random.new(SEED)
  random_width_array(network_count, random).each do |width|
    visitor = WidthCheckingVisitor.new(width)
    scheme.network(Width.from_value(width)).host(visitor, FORWARD)
  end
end

def test_sorting_with_sub_scheme(sub_scheme, network_count, visitor_factory)
  scheme = Scheme::WidthLimited.new(sub_scheme)
  random = Random.new(SEED)
  random_width_array(network_count, random).each do |width|
    a = Array.new(width) { yield random }
    b = a.clone
    c = sort(a)
    visitor = visitor_factory.new(b)
    scheme.network(Width.from_value(width)).host(visitor, FORWARD)
    b.should eq(c)
  end
end

describe Scheme::WidthLimited do
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
