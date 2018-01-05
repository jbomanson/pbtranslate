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

private MAX             = 128
private NETWORK_COUNT   =  10
private RANDOM          = Random.new(SEED)
private RANGE           = array_of_random_width(NETWORK_COUNT, RANDOM, max: MAX).map { |v| Width.from_value(v) }
private ROUNDS          = 5
private SCHEME_BALANCE  = create_scheme &.imbalance_limit=(0.0)
private SCHEME_DEFAULT  = create_scheme { }
private SCHEME_POPCOUNT = create_scheme &.popcount_limit=(1)
private SEED            = SpecHelper.file_specific_seed

describe Scheme::FlexibleDivideAndConquerDynamicProgramming do
  it_hosts_like_a_sorting_network(SCHEME_BALANCE, SEED, RANGE, ROUNDS)
  it_hosts_like_a_sorting_network(SCHEME_DEFAULT, SEED, RANGE, ROUNDS)
  it_hosts_like_a_sorting_network(SCHEME_POPCOUNT, SEED, RANGE, ROUNDS)

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    SCHEME_DEFAULT.network(Width.from_value(Distance.new(5)))
  }
end
