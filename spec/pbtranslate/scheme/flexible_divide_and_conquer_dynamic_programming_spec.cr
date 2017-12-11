require "../sorting_network_helper"

include SpecHelper

network_count = 10
scheme =
  Scheme
    .pw2_merge_odd_even
    .to_scheme_flexible_combine
    .to_scheme_flexible_divide_and_conquer_dynamic_programming
    .to_scheme_with_offset_resolution
seed = SEED ^ __FILE__.hash
random = Random.new(seed)
log_max = Distance.new(7)
range = array_of_random_width(network_count, random, log_max).map { |v| Width.from_value(v) }
rounds = 5

describe Scheme::FlexibleDivideAndConquerDynamicProgramming do
  it_hosts_like_a_sorting_network(scheme, seed, range, rounds)
end
