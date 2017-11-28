require "../sorting_network_helper"

include SpecHelper

network_count = 10
scheme =
  Scheme::OffsetResolution.new(
    Scheme::BestSplitMergeSort.new(
      Scheme::FlexibleMerge.new(
        Scheme::OddEvenPw2Merge::INSTANCE
      )
    )
  )
seed = SEED ^ __FILE__.hash
random = Random.new(seed)
log_max = Distance.new(7)
range = random_width_array(network_count, random, log_max).map { |v| Width.from_value(v) }
rounds = 5

describe Scheme::BestSplitMergeSort do
  it_hosts_like_a_sorting_network(scheme, seed, range, rounds)
end
