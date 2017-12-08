require "../scheme/flexible_divide_and_conquer_dynamic_programming"
require "../scheme/partial_flexible_sort_hard_coded"
require "../scheme/pw2_merge_odd_even"
require "../scheme/flexible"
require "../scheme/offset_resolution"

class PBTranslate::Tool
  BASE_SCHEME =
    Scheme
      .pw2_merge_odd_even
      .to_scheme_flexible_combine
      .to_scheme_flexible_divide_and_conquer_dynamic_programming(Scheme.partial_flexible_sort_hard_coded)
      .to_scheme_with_offset_resolution.as(Scheme::Flexible)
end
