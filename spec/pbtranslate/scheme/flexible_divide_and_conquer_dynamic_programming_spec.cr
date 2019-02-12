require "../../bidirectional_host_helper"
require "../sorting_network_helper"

include SpecHelper

private def create_scheme
  dynamic_programming_scheme =
    Scheme
      .pw2_merge_odd_even
      .to_scheme_flexible_combine
      .to_scheme_flexible_divide_and_conquer_dynamic_programming
  yield dynamic_programming_scheme
  dynamic_programming_scheme.to_scheme_with_offset_resolution
end

max = 128
network_count = 10
reference_scheme =
  Scheme.pw2_merge_odd_even
    .to_scheme_pw2_divide_and_conquer
    .to_scheme_with_offset_resolution
    .to_scheme_flexible
rounds = 5
scheme_balance = create_scheme &.imbalance_limit=(0.0)
scheme_default = create_scheme { }
scheme_popcount = create_scheme &.popcount_limit=(1)
seed = SpecHelper.file_specific_seed
costs = PBTranslate::Scheme::FlexibleDivideAndConquerDynamicProgramming::FUNCTION_NAME_COSTS

random = Random.new(seed)
range = array_of_random_width(network_count, random, max: max).map { |v| Width.from_value(v) }

describe Scheme::FlexibleDivideAndConquerDynamicProgramming do
  it_hosts_like_a_sorting_network(scheme_balance, seed, range, rounds)
  it_hosts_like_a_sorting_network(scheme_default, seed, range, rounds)
  it_hosts_like_a_sorting_network(scheme_popcount, seed, range, rounds)

  0.upto(20).each do |width_int|
    it "squeezes #{width_int}-networks as popcount_limit increases" do
      width = Width.from_value(Distance.new(width_int))
      0.upto(32).map do |popcount_limit|
        create_scheme(&.popcount_limit=(popcount_limit))
          .network(width)
          .compute_gate_cost(costs)
      end.each_cons(2) do |pair|
        pair.first.should be >= pair.last
      end
    end
  end

  0.upto(7).each do |power_int|
    width_int = 1 << power_int
    it "is no worse than odd-even #{width_int} sorting networks" do
      width = Width.from_value(Distance.new(width_int))
      reference_cost = reference_scheme.network(width).compute_gate_cost(costs)
      [scheme_balance, scheme_default, scheme_popcount].each do |scheme|
        scheme
          .network(width)
          .compute_gate_cost(costs).should be <= reference_cost
      end
    end
  end

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    scheme_default.network(Width.from_value(Distance.new(5)))
  }
end
