require "../network/pw2_merge_direct"
require "./pw2_combine"

# :nodoc:
struct PBTranslate::Scheme::Pw2MergeDirect
  include Pw2Combine
  include Scheme

  module ::PBTranslate
    # A scheme of networks of depth one or two that merge pairs of sorted
    # sequences of equal lengths that are powers of two.
    #
    # A network from this scheme is of quadratic size.
    # That is, a network of *n* inputs has *O(n^2)* gates.
    def Scheme.pw2_merge_direct : Pw2Combine
      Pw2MergeDirect.new
    end
  end

  declare_gate_options

  def network(half_width : Width::Pw2)
    Network::Pw2MergeDirect.new(half_width.log2)
  end
end
