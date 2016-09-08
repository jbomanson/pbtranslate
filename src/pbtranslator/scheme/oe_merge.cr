require "../network/oe_merge"

module PBTranslator

  # An OEMerge scheme represents Batcher's odd-even merging networks.
  #
  # They are _comparator networks_.
  # The gates in these networks are comparators.
  # Instances of these networks are obtained via `#network`.
  class Scheme::OEMerge

    # The only instance of the OEMerge scheme that needs to be used.
    #
    # To obtain instances of networks, use `#network`.
    INSTANCE = self.new

    # Returns a `Network::OEMerge` instance for merging pairs of consecutive
    # sequences of of the same width that is a power of two.
    #
    # The binary logarithm of the width of both of these halves is
    # *half_width_log2*.
    def network(half_width_log2)
      Network::OEMerge.new(half_width_log2)
    end

  end

end
