class PBTranslate::Tool
  BASE_SCHEME =
    Scheme::OffsetResolution.new(
      Scheme::BestSplitMergeSort.new(
        base_scheme:
          Network::HardCodedSort,
        merge_scheme:
          Scheme::FlexibleMerge.new(
            Scheme::OddEvenMerge::INSTANCE
          ),
      )
    ).as(Scheme::OfAnyWidth)
end
