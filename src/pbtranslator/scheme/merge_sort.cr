require "../gate_options"
require "../network/merge_sort"

# A MergeSort scheme implements traditional merge sorting using a scheme of
# type *S* for sorting subsequences and a scheme of type *M* for merging
# them.
class PBTranslator::Scheme::MergeSort(S, M)
  # A MergeSort scheme for sorting via recursive merging.
  struct Recursive(M)
    include GateOptions::Module

    delegate gate_options, to: @merge_scheme

    # Creates a MergeSort scheme that sorts subsequences by recursively
    # merging them according to *merge_scheme*.
    def initialize(@merge_scheme : M)
    end

    def network(width : Width::Pw2)
      Network::MergeSort.new(self, @merge_scheme, width.log2)
    end
  end

  # A MergeSort scheme for sorting with a base case or via recursive merging.
  struct RecursiveFallback(P, M)
    include GateOptions::Module

    delegate gate_options, to: (true ? @primary_scheme : @merge_scheme)

    def initialize(@primary_scheme : P, @merge_scheme : M)
    end

    def network(width : Width::Pw2)
      (@primary_scheme.network? width) ||
        Network::MergeSort.new(self, @merge_scheme, width.log2)
    end
  end

  include GateOptions::Module

  delegate gate_options, to: (true ? @sort_scheme : @merge_scheme)

  # Creates a MergeSort scheme that sorts subsequences according to
  # *sort_scheme* and merges them according to *merge_scheme*.
  def initialize(@sort_scheme : S, @merge_scheme : M)
  end

  def network(width : Width::Pw2)
    Network::MergeSort.new(@sort_scheme, @merge_scheme, width.log2)
  end
end
