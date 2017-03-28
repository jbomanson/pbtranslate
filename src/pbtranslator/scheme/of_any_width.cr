module PBTranslator::Scheme
  module OfAnyWidthMarker
    abstract def network(width w : Width)
  end

  alias OfAnyWidth = OfAnyWidthMarker |
                     OffsetResolution(BestSplitMergeSort(Network::HardCodedSort.class, FlexibleMerge(OEMerge))) |
                     WithFallback(Network::HardCodedSort.class, OfAnyWidthMarker)
end
