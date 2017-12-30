require "../sorting_network_helper"

include PBTranslate

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)
rounds = 5
private SEED = SpecHelper.file_specific_seed
scheme = SpecHelper.pw2_sort_odd_even

describe Scheme::Pw2DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, SEED, range, rounds)
end

scheme = SpecHelper.pw2_sort_odd_even(Scheme.partial_flexible_sort_hard_coded)

describe Scheme::Pw2DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, SEED, range, rounds)
end
