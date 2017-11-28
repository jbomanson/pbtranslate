require "../network/direct_pw2_merge"
require "./pw2_conquer"

# A scheme of networks of depth one or two that merge pairs of sorted
# sequences of equal lengths that are powers of two.
#
# A network from this scheme is of quadratic size.
# That is, a network of *n* inputs has *O(n^2)* gates.
struct PBTranslate::Scheme::DirectPw2Merge
  include Pw2Conquer
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
    Network::DirectPw2Merge.new(half_width.log2)
  end
end
