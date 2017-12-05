require "../sorting_network_helper"

include PBTranslate

range = WidthRange.new(Scheme::FlexiblePartialSortHardCoded.width_value_range)

rounds = 400

seed = SEED ^ __FILE__.hash

scheme = Scheme::FlexiblePartialSortHardCoded

describe Scheme::FlexiblePartialSortHardCoded do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end
