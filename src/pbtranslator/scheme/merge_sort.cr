require "./one_way"
require "../network/merge_sort"

module PBTranslator

  # A MergeSort scheme implements traditional merge sorting using a scheme of
  # type *S* for sorting subsequences and a scheme of type *M* for merging
  # them.
  class Scheme::MergeSort(S, M) < Scheme::OneWay

    # A MergeSort scheme for sorting via recursive merging.
    struct Recursive(M)

      # Creates a MergeSort scheme that sorts subsequences by recursively
      # merging them according to *merge_scheme*.
      def initialize(@merge_scheme : M)
      end

      def network(width_log2)
        Network::MergeSort.new(self, @merge_scheme, width_log2)
      end

    end

    # Creates a MergeSort scheme that sorts subsequences according to
    # *sort_scheme* and merges them according to *merge_scheme*.
    def initialize(@sort_scheme : S, @merge_scheme : M)
    end

    def network(width_log2)
      Network::MergeSort.new(@sort_scheme, @merge_scheme, width_log2)
    end

  end
end
