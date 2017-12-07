require "../network/pw2_divide_and_conquer"
require "./partial_flexible_void"
require "../scheme"

# :nodoc:
class PBTranslate::Scheme::Pw2DivideAndConquer(M, Q)
  include Scheme

  module ::PBTranslate::Scheme::Pw2Combine
    # Creates a divide and conquer scheme which divides input sequences in
    # halves of equal length that is a power of two.
    # Conquer actions are implemented using either the given *base_scheme* or
    # the created scheme recursively.
    # Combination actions are implemented using this scheme.
    #
    # The given base_scheme is optional, it is allwoed to be partial and it is
    # enough for it to generate networks of widths that are powers of two.
    def to_scheme_pw2_divide_and_conquer(
                                         base_scheme = PartialFlexibleVoid::INSTANCE) : Scheme
      Pw2DivideAndConquer.new(self, base_scheme)
    end
  end

  delegate gate_options, to: (true ? @combine_scheme : @base_scheme)

  def initialize(@combine_scheme : M, @base_scheme : Q)
  end

  def network(width : Width::Pw2)
    (@base_scheme.network? width) || recursive_network(width)
  end

  private def recursive_network(width)
    Network::Pw2DivideAndConquer.new(width, @combine_scheme, self)
  end
end
