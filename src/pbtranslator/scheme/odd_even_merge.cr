require "../scheme"
require "../network/odd_even_merge"

# An OddEvenMerge scheme represents Batcher's odd-even merging networks.
#
# They are _comparator networks_.
# The gates in these networks are comparators.
# Instances of these networks are obtained via `#network`.
class PBTranslator::Scheme::OddEvenMerge
  include Scheme

  # The only instance of the OddEvenMerge scheme that needs to be used.
  #
  # To obtain instances of networks, use `#network`.
  INSTANCE = new

  declare_gate_options

  # Returns a `Network::OddEvenMerge` instance for merging pairs of consecutive
  # sequences of of the same width that is a power of two.
  #
  # The binary logarithm of the width of both of these halves is
  # *half_width_log2*.
  def network(half_width : Width::Pw2)
    Network::OddEvenMerge.new(half_width.log2)
  end
end
