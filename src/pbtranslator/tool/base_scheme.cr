class PBTranslator::Tool
  BASE_SCHEME =
    Scheme::OffsetResolution.new(
      Scheme::BestSplitMergeSort.new(
        base_scheme:
          Network::HardCodedSort,
        merge_scheme:
          Scheme::FlexibleMerge.new(
            Scheme::OEMerge::INSTANCE
          ),
      )
    ).as(Scheme::OfAnyWidth)
end
