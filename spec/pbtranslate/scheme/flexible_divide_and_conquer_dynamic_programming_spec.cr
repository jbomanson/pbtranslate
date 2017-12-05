require "../sorting_network_helper"

include SpecHelper

network_count = 10
scheme =
  Scheme::OffsetResolution.new(
    Scheme::FlexibleDivideAndConquerDynamicProgramming.new(
      Scheme::FlexibleCombineFromPw2Combine.new(
        Scheme::Pw2MergeOddEven::INSTANCE
      )
    )
  )
seed = SEED ^ __FILE__.hash
random = Random.new(seed)
log_max = Distance.new(7)
range = random_width_array(network_count, random, log_max).map { |v| Width.from_value(v) }
rounds = 5

describe Scheme::FlexibleDivideAndConquerDynamicProgramming do
  it_hosts_like_a_sorting_network(scheme, seed, range, rounds)
end