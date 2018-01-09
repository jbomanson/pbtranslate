require "../../bidirectional_host_helper"
require "../sorting_network_helper"

include PBTranslate

private class MergeSortByDivideAndConquerScheme(M)
  include Scheme
  include Scheme::WithArguments(Width::Flexible)

  def initialize(@merge_scheme : M)
  end

  def network(width : Width)
    w = width.value
    l = Width.from_value((w + 1) / 2)
    r = Width.from_value(w / 2)
    case w
    when 0, 1 then Network.empty
    when    2 then base_case(l, r)
    else           recursive_case(l, r)
    end
  end

  private def base_case(l, r)
    @merge_scheme.network({l, r})
  end

  private def recursive_case(l, r)
    Network::DivideAndConquer.new(
      widths: {l, r},
      conquer_scheme: self,
      combine_scheme: @merge_scheme,
    )
  end
end

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)
rounds = 5
private SEED = SpecHelper.file_specific_seed
scheme =
  MergeSortByDivideAndConquerScheme.new(
    Scheme.pw2_merge_odd_even.to_scheme_flexible_combine
  ).to_scheme_with_offset_resolution

describe Network::DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, SEED, range, rounds)

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    scheme.network(Width.from_log2(Distance.new(3)))
  }
end
