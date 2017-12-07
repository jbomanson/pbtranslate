require "../scheme/flexible_divide_and_conquer_dynamic_programming"
require "../scheme/partial_flexible_sort_hard_coded"
require "../scheme/pw2_merge_odd_even"
require "../scheme/flexible"
require "../scheme/offset_resolution"

class PBTranslate::Tool
  BASE_SCHEME =
    Scheme::OffsetResolution.new(
      Scheme::FlexibleDivideAndConquerDynamicProgramming.new(
        base_scheme: Scheme.partial_flexible_sort_hard_coded,
        combine_scheme: Scheme::FlexibleCombineFromPw2Combine.new(
          Scheme.pw2_merge_odd_even
        ),
      )
    ).as(Scheme::Flexible)
end
