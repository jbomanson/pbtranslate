require "../sorting_network_helper"

include PBTranslate

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)

rounds = 5

seed = SEED ^ __FILE__.hash

scheme =
  Scheme::OffsetResolution.new(
    Scheme::Pw2DivideAndConquer.new(
      Scheme::Pw2MergeOddEven::INSTANCE
    )
  )

describe Scheme::Pw2DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end

scheme =
  Scheme::OffsetResolution.new(
    Scheme::Pw2DivideAndConquer.new(
      Scheme::Pw2MergeOddEven::INSTANCE,
      base_scheme: Scheme::FlexiblePartialSortHardCoded,
    )
  )

describe Scheme::Pw2DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end
