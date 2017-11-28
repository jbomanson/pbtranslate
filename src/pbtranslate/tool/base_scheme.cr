require "../scheme/best_split_merge_sort"
require "../scheme/hard_coded_sort"
require "../scheme/odd_even_pw2_merge"
require "../scheme/of_any_width"
require "../scheme/offset_resolution"

class PBTranslate::Tool
  BASE_SCHEME =
    Scheme::OffsetResolution.new(
      Scheme::BestSplitMergeSort.new(
        base_scheme: Scheme::HardCodedSort,
        merge_scheme: Scheme::FlexibleMerge.new(
          Scheme::OddEvenPw2Merge::INSTANCE
        ),
      )
    ).as(Scheme::OfAnyWidth)
end
