require "../network/pw2_divide_and_conquer"
require "./partial_flexible_void"
require "../scheme"

# A scheme for divide and conquer algorithms that divide input sequences in
# halves of equal length that is a power of two.
# Conquer actions are implemented using either a scheme of type *Q* or this
# scheme recursively.
# Combination actions are implemented using a scheme of type *M*.
# are powers of two by using a scheme of type *Q* as a base cas#
#
# It is enough for these parameter schemes to generate networks of widths that
# are powers of two.
#
# The scheme of type *Q* is optional, and if it is specified it only needs to
# implement `#network?`.
class PBTranslate::Scheme::Pw2DivideAndConquer(M, Q)
  include Scheme

  delegate gate_options, to: (true ? @merge_scheme : @base_scheme)

  # Creates a scheme that conquers recursively and combines the results using
  # *merge_scheme*.
  def self.new(merge_scheme)
    new(merge_scheme, base_scheme: PartialFlexibleVoid::INSTANCE)
  end

  # Creates a scheme that conquers subsequences using *base_scheme* or itself
  # and combines the results using *merge_scheme*.
  def initialize(@merge_scheme : M, *, @base_scheme : Q)
  end

  # Generates a network of *width*.
  def network(width : Width::Pw2)
    (@base_scheme.network? width) || recursive_network(width)
  end

  private def recursive_network(width)
    Network::Pw2DivideAndConquer.new(width, @merge_scheme, self)
  end
end
