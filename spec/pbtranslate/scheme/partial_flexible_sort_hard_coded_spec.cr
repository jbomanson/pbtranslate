require "../sorting_network_helper"

include PBTranslate

range = WidthRange.new(Scheme::PartialFlexibleSortHardCoded.width_value_range)

rounds = 400

private SEED = SpecHelper.file_specific_seed

scheme = Scheme::PartialFlexibleSortHardCoded

describe Scheme::PartialFlexibleSortHardCoded do
  it_acts_like_a_sorting_network(scheme, SEED, range, rounds)
end
