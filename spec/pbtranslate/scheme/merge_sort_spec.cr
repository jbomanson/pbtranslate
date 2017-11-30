require "../sorting_network_helper"

include PBTranslate

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)

rounds = 5

seed = SEED ^ __FILE__.hash

scheme =
  Scheme::OffsetResolution.new(
    Scheme::MergeSort.new(
      Scheme::OddEvenPw2Merge::INSTANCE
    )
  )

describe Scheme::MergeSort do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end

scheme =
  Scheme::OffsetResolution.new(
    Scheme::MergeSort.new(
      Scheme::OddEvenPw2Merge::INSTANCE,
      base_scheme: Scheme::HardCodedSort,
    )
  )

describe Scheme::MergeSort do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end
