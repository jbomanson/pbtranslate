class PBTranslator::Tool
  BASE_SCHEME =
    Scheme::WithFallback.new(
      Network::HardCodedSort,
      Scheme::WidthLimited.new(
        Scheme::MergeSort::RecursiveFallback.new(
          Network::HardCodedSort,
          Scheme::OEMerge::INSTANCE
        )
      ).as(Scheme::OfAnyWidthMarker)
    ).as(Scheme::OfAnyWidth)
end
