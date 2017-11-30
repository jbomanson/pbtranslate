require "../network/merge_sort"
require "./nonexistent"
require "../scheme"

# A scheme that implements traditional merge sorting for inputs of lengths that
# are powers of two by using a scheme of type *R* or itself to sort
# subsequences and a scheme of type *E* to merge them.
#
# It is enough for these parameter schemes to generate networks of widths that
# are powers of two.
#
# The scheme of type *R* is optional, and if it is specified it only needs to
# implement `#network?`.
class PBTranslate::Scheme::MergeSort(R, E)
  include Scheme

  delegate gate_options, to: (true ? @merge_scheme : @base_scheme)

  # Creates a scheme that conquers recursively and combines the results using
  # *merge_scheme*.
  def self.new(merge_scheme)
    new(merge_scheme, base_scheme: Nonexistent::INSTANCE)
  end

  # Creates a scheme that conquers subsequences using *base_scheme* or itself
  # and combines the results using *merge_scheme*.
  def initialize(@merge_scheme : E, *, @base_scheme : R)
  end

  # Generates a network of *width*.
  def network(width : Width::Pw2)
    (@base_scheme.network? width) || recursive_network(width)
  end

  private def recursive_network(width)
    Network::MergeSort.new(self, @merge_scheme, width)
  end
end
