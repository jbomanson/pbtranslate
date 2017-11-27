require "../scheme"
require "../network/odd_even_merge"

# A scheme for generating Batcher's odd-even merging networks.
#
# An odd-even merging network of *n* inputs has *O(log n)* layers and
# *O(n log n)* gates.
# A recursive merge sorting network constructed using odd-even merging networks
# has *O((log n)^2)* layers and *O(n (log n)^2)* gates.
# Such a network can be created by calling
# `Scheme::MergeSort::Recursive.new(Scheme::OddEvenMerge::INSTANCE)`.
#
# See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
# See https://gist.github.com/Bekbolatov/c8e42f5fcaa36db38402
class PBTranslate::Scheme::OddEvenMerge
  include Scheme

  # An instance of this scheme.
  INSTANCE = new

  declare_gate_options

  # :nodoc:
  def initialize
  end

  # Generates a network that merges pairs of sorted sequences each of length
  # *half_width*.
  def network(half_width : Width::Pw2)
    Network::OddEvenMerge.new(half_width.log2)
  end
end
