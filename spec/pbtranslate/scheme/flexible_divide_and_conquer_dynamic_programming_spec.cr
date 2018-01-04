require "../sorting_network_helper"

include SpecHelper

private NETWORK_COUNT = 10
private SCHEME        =
  Scheme
    .pw2_merge_odd_even
    .to_scheme_flexible_combine
    .to_scheme_flexible_divide_and_conquer_dynamic_programming
    .to_scheme_with_offset_resolution
private SEED   = SpecHelper.file_specific_seed
private RANDOM = Random.new(SEED)
private MAX    = 128
private RANGE  = array_of_random_width(NETWORK_COUNT, RANDOM, max: MAX).map { |v| Width.from_value(v) }
private ROUNDS = 5

describe Scheme::FlexibleDivideAndConquerDynamicProgramming do
  it_hosts_like_a_sorting_network(SCHEME, SEED, RANGE, ROUNDS)
end
