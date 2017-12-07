require "../sorting_network_helper"

include PBTranslate

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)

rounds = 5

seed = SEED ^ __FILE__.hash

scheme =
  Scheme::OffsetResolution.new(
    Scheme::Pw2DivideAndConquer.new(
      Scheme.pw2_merge_odd_even
    )
  )

describe Scheme::Pw2DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end

scheme =
  Scheme::OffsetResolution.new(
    Scheme::Pw2DivideAndConquer.new(
      Scheme.pw2_merge_odd_even,
      base_scheme: Scheme::PartialFlexibleSortHardCoded,
    )
  )

describe Scheme::Pw2DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end
