require "./one_way"
require "../network/direct_merge"

module PBTranslator

  # A DirectMerge scheme represents class of networks of bounded depth that
  # merge Booleans.
  #
  # The methods of this scheme are parametrized by the logarithm of the half
  # width of the produced networks.
  class Scheme::DirectMerge

    INSTANCE = new

    def network(half_width_log2)
      Network::DirectMerge.new(half_width_log2)
    end

  end

end
