require "../sorting_network_helper"

include PBTranslate

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)

rounds = 5

seed = SEED ^ __FILE__.hash

scheme_a = Scheme.partial_flexible_sort_hard_coded

scheme_b =
  Scheme.pw2_merge_odd_even
        .to_scheme_pw2_divide_and_conquer
        .to_scheme_with_offset_resolution

scheme = scheme_a.to_scheme_with_fallback(scheme_b)

describe Scheme::WithFallback do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end
