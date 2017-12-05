require "../scheme/flexible_divide_and_conquer_dynamic_programming"
require "../scheme/flexible_partial_sort_hard_coded"
require "../scheme/pw2_merge_odd_even"
require "../scheme/flexible"
require "../scheme/offset_resolution"

class PBTranslate::Tool
  BASE_SCHEME =
    Scheme::OffsetResolution.new(
      Scheme::FlexibleDivideAndConquerDynamicProgramming.new(
        base_scheme: Scheme::FlexiblePartialSortHardCoded,
        merge_scheme: Scheme::FlexibleCombineFromPw2Combine.new(
          Scheme::Pw2MergeOddEven::INSTANCE
        ),
      )
    ).as(Scheme::Flexible)
end
