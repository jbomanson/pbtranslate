require "../../bidirectional_host_helper"
require "../../spec_helper"

include SpecHelper

private SEED = SpecHelper.file_specific_seed
network_count = 10

oe_scheme =
  Scheme.pw2_merge_odd_even
        .to_scheme_pw2_divide_and_conquer
        .to_scheme_with_offset_resolution

direct_scheme =
  Scheme.pw2_merge_direct
        .to_scheme_pw2_divide_and_conquer
        .to_scheme_with_offset_resolution

private def test_limits_with_sub_scheme(sub_scheme, network_count)
  scheme = Scheme::FlexibleFromPw2.new(sub_scheme)
  random = Random.new(SEED)
  array_of_random_width(network_count, random).each do |width|
    visitor = WidthCheckingVisitor.new(width)
    scheme.network(Width.from_value(width)).host(visitor)
  end
end

private def test_sorting_with_sub_scheme(sub_scheme, network_count, visitor_factory)
  scheme = Scheme::FlexibleFromPw2.new(sub_scheme)
  random = Random.new(SEED)
  array_of_random_width(network_count, random).each do |width|
    a = Array.new(width) { yield random }
    b = a.clone
    c = sort(a)
    visitor = visitor_factory.new(b)
    scheme.network(Width.from_value(width)).host(visitor)
    b.should eq(c)
  end
end

describe Scheme::FlexibleFromPw2 do
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

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    oe_scheme.to_scheme_flexible.network(Width.from_log2(Distance.new(3)))
  }

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    direct_scheme.to_scheme_flexible.network(Width.from_log2(Distance.new(3)))
  }
end
