module PBTranslator::Scheme
  module OfAnyWidthMarker
    abstract def network(width w : Width)
  end

  alias OfAnyWidth = OfAnyWidthMarker |
                     WithFallback(Network::HardCodedSort.class, OfAnyWidthMarker)
end
