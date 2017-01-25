class PBTranslator::Tool
  BASE_SCHEME =
    Scheme::WidthLimited.new(
      Scheme::MergeSort::Recursive.new(
        Scheme::OEMerge::INSTANCE
      )
    )
end
