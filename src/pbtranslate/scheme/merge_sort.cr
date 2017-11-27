require "../scheme"
require "../network/merge_sort"

# A scheme that implements traditional merge sorting for inputs of lengths that
# are powers of two using a scheme of type *S* for sorting subsequences and a
# scheme of type *M* for merging them.
#
# It is enough for these parameter schemes of types *S* and *M* to generate
# networks for inputs of lengths that are powers of two.
#
# There are two other classes, `Recursive` and `RecursiveFallback`, which
# provide recursive merge sorting where the subsequences are sorted by merging
# shorter subsequences, which are obtained by sorting even shorter subsequences
# etc.
class PBTranslate::Scheme::MergeSort(S, M)
  # A scheme for sorting via recursive merging by applying a single scheme of
  # type *M* for merging subsequences into larger and larger sorted sequences.
  struct Recursive(M)
    include Scheme

    delegate gate_options, to: @merge_scheme

    # Creates a MergeSort scheme that sorts subsequences by recursively
    # merging them according to *merge_scheme*.
    def initialize(@merge_scheme : M)
    end

    # Generates a network that sorts sequences of length *width*.
    def network(width : Width::Pw2)
      Network::MergeSort.new(self, @merge_scheme, width)
    end
  end

  # A scheme similar to `Recursive`, but with an additional primary partial
  # scheme parameter of type *P* that is used for short sorting subsequences.
  struct RecursiveFallback(P, M)
    include Scheme

    delegate gate_options, to: (true ? @primary_scheme : @merge_scheme)

    # Creates a MergeSort scheme that sorts subsequences either according to
    # *primary_scheme* or by recursively merging them according to
    # *merge_scheme*.
    def initialize(@primary_scheme : P, @merge_scheme : M)
    end

    # Generates a network that sorts sequences of length *width*.
    def network(width : Width::Pw2)
      (@primary_scheme.network? width) ||
        Network::MergeSort.new(self, @merge_scheme, width)
    end
  end

  include Scheme

  delegate gate_options, to: (true ? @sort_scheme : @merge_scheme)

  # Creates a MergeSort scheme that sorts subsequences according to
  # *sort_scheme* and merges them according to *merge_scheme*.
  def initialize(@sort_scheme : S, @merge_scheme : M)
  end

  # Generates a network that sorts sequences of length *width*.
  def network(width : Width::Pw2)
    Network::MergeSort.new(@sort_scheme, @merge_scheme, width)
  end
end
