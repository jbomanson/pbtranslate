class PBTranslator::Tool
  BASE_SCHEME =
    Scheme::WithFallback.new(
      Network::HardCodedSort,
      Scheme::WidthLimited.new(
        Scheme::MergeSort::Recursive.new(
          Scheme::OEMerge::INSTANCE
        )
      ).as(Scheme::OfAnyWidthMarker)
    ).as(Scheme::OfAnyWidth)
end
