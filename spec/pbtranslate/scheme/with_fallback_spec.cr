require "../../bidirectional_host_helper"
require "../sorting_network_helper"

include PBTranslate

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)
rounds = 5
seed = SpecHelper.file_specific_seed
scheme_a = Scheme.partial_flexible_sort_hard_coded
scheme_b = SpecHelper.pw2_sort_odd_even
scheme = scheme_a.to_scheme_with_fallback(scheme_b)

describe Scheme::WithFallback do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    scheme.network(Width.from_log2(Distance.new(3)))
  }
end
