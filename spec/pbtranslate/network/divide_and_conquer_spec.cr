require "../sorting_network_helper"

include PBTranslate

class MergeSortByDivideAndConquerScheme(M)
  include Scheme

  declare_gate_options

  def initialize(@merge_scheme : M)
  end

  def network(width : Width)
    w = width.value
    l = Width.from_value((w + 1) / 2)
    r = Width.from_value(w / 2)
    case w
    when 0, 1 then Network::Empty::INSTANCE
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
seed = SEED ^ __FILE__.hash
scheme =
  Scheme::OffsetResolution.new(
    MergeSortByDivideAndConquerScheme.new(
      Scheme::FlexibleCombineFromPw2Combine.new(
        Scheme.pw2_merge_odd_even
      )
    )
  )

describe Network::DivideAndConquer do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end
