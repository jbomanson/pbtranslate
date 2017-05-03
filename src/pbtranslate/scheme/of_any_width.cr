module PBTranslate::Scheme
  module OfAnyWidthMarker
    abstract def network(width w : Width)
  end

  alias OfAnyWidth = OfAnyWidthMarker |
                     OffsetResolution(BestSplitMergeSort(Network::HardCodedSort.class, FlexibleMerge(OddEvenMerge))) |
                     WithFallback(Network::HardCodedSort.class, OfAnyWidthMarker)
end
