require "../sorting_network_helper"

include PBTranslate

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)

rounds = 5

seed = SEED ^ __FILE__.hash

scheme_a = Scheme::HardCodedSort

scheme_b =
  Scheme::OffsetResolution.new(
    Scheme::MergeSort::Recursive.new(
      Scheme::OddEvenPw2Merge::INSTANCE
    )
  )

scheme = Scheme::WithFallback.new(scheme_a, scheme_b)

describe Scheme::WithFallback do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end
