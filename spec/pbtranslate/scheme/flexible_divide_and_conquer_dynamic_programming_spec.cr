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

private MAX              = 128
private NETWORK_COUNT    =  10
private RANDOM           = Random.new(SEED)
private RANGE            = array_of_random_width(NETWORK_COUNT, RANDOM, max: MAX).map { |v| Width.from_value(v) }
private REFERENCE_SCHEME =
  Scheme.pw2_merge_odd_even
        .to_scheme_pw2_divide_and_conquer
        .to_scheme_with_offset_resolution
        .to_scheme_flexible
private ROUNDS          = 5
private SCHEME_BALANCE  = create_scheme &.imbalance_limit=(0.0)
private SCHEME_DEFAULT  = create_scheme { }
private SCHEME_POPCOUNT = create_scheme &.popcount_limit=(1)
private SEED            = SpecHelper.file_specific_seed
private COSTS           = PBTranslate::Scheme::FlexibleDivideAndConquerDynamicProgramming::FUNCTION_NAME_COSTS

describe Scheme::FlexibleDivideAndConquerDynamicProgramming do
  it_hosts_like_a_sorting_network(SCHEME_BALANCE, SEED, RANGE, ROUNDS)
  it_hosts_like_a_sorting_network(SCHEME_DEFAULT, SEED, RANGE, ROUNDS)
  it_hosts_like_a_sorting_network(SCHEME_POPCOUNT, SEED, RANGE, ROUNDS)

  0.upto(20).each do |width_int|
    it "squeezes #{width_int}-networks as popcount_limit increases" do
      width = Width.from_value(Distance.new(width_int))
      0.upto(32).map do |popcount_limit|
        create_scheme(&.popcount_limit=(popcount_limit))
          .network(width)
          .compute_gate_cost(COSTS)
      end.each_cons(2) do |pair|
        pair.first.should be >= pair.last
      end
    end
  end

  0.upto(7).each do |power_int|
    width_int = 1 << power_int
    it "is no worse than odd-even #{width_int} sorting networks" do
      width = Width.from_value(Distance.new(width_int))
      reference_cost = REFERENCE_SCHEME.network(width).compute_gate_cost(COSTS)
      [SCHEME_BALANCE, SCHEME_DEFAULT, SCHEME_POPCOUNT].each do |scheme|
        scheme
          .network(width)
          .compute_gate_cost(COSTS).should be <= reference_cost
      end
    end
  end

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    SCHEME_DEFAULT.network(Width.from_value(Distance.new(5)))
  }
end
