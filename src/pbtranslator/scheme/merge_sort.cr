require "./one_way"
require "../network/merge_sort"

module PBTranslator

  # A MergeSort scheme implements traditional merge sorting using a scheme of
  # type *S* for sorting subsequences and the `OEMerge` scheme for merging
  # them.
  class Scheme::MergeSort(S) < Scheme::OneWay

    # A MergeSort scheme for sorting via recursive merging.
    #
    # See `DEFAULT_INSTANCE`.
    alias Recursive = MergeSort(Recursive)

    # A `Recursive` scheme instance.
    DEFAULT_INSTANCE = MergeSort(Recursive).new

    @sort_scheme : S

    # Creates a MergeSort scheme that sorts subsequences using *sort_scheme*.
    def initialize(@sort_scheme : S)
    end

    # Creates a recursive MergeSort scheme.
    def initialize
      initialize(self)
    end

    def network(width_log2)
      Network::MergeSort.new(@sort_scheme, width_log2)
    end

  end
end
