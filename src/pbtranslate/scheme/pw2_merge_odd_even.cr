require "../network/pw2_merge_odd_even"
require "./pw2_combine"
require "../scheme"

# A scheme for generating Batcher's odd-even merging networks.
#
# An odd-even merging network of *n* inputs has *O(log n)* layers and
# *O(n log n)* gates.
# A recursive merge sorting network constructed using odd-even merging networks
# has *O((log n)^2)* layers and *O(n (log n)^2)* gates.
# Such a network can be created by calling
# `Scheme::Pw2DivideAndConquer.new(Scheme::Pw2MergeOddEven::INSTANCE)`.
#
# See https://en.wikipedia.org/wiki/Batcher_odd%E2%80%93even_mergesort
# See https://gist.github.com/Bekbolatov/c8e42f5fcaa36db38402
class PBTranslate::Scheme::Pw2MergeOddEven
  include Pw2Combine
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
    Network::Pw2MergeOddEven.new(half_width.log2)
  end
end
