require "../sorting_network_helper"

include PBTranslate

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)

rounds = 5

seed = SEED ^ __FILE__.hash

scheme =
  Scheme::Pw2DivideAndConquer.new(
    Scheme.pw2_merge_odd_even
  ).to_scheme_with_offset_resolution

describe Scheme::Pw2DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end

scheme =
  Scheme::Pw2DivideAndConquer.new(
    Scheme.pw2_merge_odd_even,
    base_scheme: Scheme.partial_flexible_sort_hard_coded,
  ).to_scheme_with_offset_resolution

describe Scheme::Pw2DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end
