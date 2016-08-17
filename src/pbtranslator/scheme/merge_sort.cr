require "./one_way"
require "./oe_merge"

module PBTranslator

  # A MergeSort scheme implements traditional merge sorting using the `OEMerge`
  # scheme for merging.
  class Scheme::MergeSort(T) < Scheme::OneWay

    alias Recursive = MergeSort(Recursive)

    DEFAULT_INSTANCE = MergeSort(Recursive).new

    @sort_scheme : T

    # Creates a MergeSort scheme that sorts subsequences using *sort_scheme*.
    def initialize(@sort_scheme : T)
    end

    # Creates a recursive MergeSort scheme.
    def initialize
      initialize(self)
    end

    # :nodoc:
    macro three_cases(zero, one_call, else_expr)
      less = width_log2 - 1
      case width_log2
      when typeof(width_log2).new(0)
        {{zero}}
      when typeof(width_log2).new(1)
        Scheme::OEMerge::INSTANCE.{{one_call}}
      else
        {{else_expr}}
      end
    end

    def size(width_log2)
      three_cases(
        typeof(width_log2).new(0),
        size(less),
        @sort_scheme.size(less) * 2 + Scheme::OEMerge::INSTANCE.size(less),
      )
    end
    
    def depth(width_log2)
      three_cases(
        typeof(width_log2).new(0),
        depth(less),
        @sort_scheme.depth(less) + Scheme::OEMerge::INSTANCE.depth(less),
      )
    end

    private def helper_visit(width_log2, *args) : Void
      three_cases(
        nil,
        visit(less, *args),
        yield less, typeof(less).new(1) << less,
      )
    end
    
    def visit(width_log2, offset, visitor)
      helper_visit(width_log2, offset, visitor) do |less, more|
        @sort_scheme.visit(less, offset, visitor)
        @sort_scheme.visit(less, offset + more, visitor)
        Scheme::OEMerge::INSTANCE.visit(less, offset, visitor)
      end
    end

    def reverse_visit(width_log2, offset, visitor)
      helper_visit(width_log2, offset, visitor) do |less, more|
        Scheme::OEMerge::INSTANCE.reverse_visit(less, offset, visitor)
        @sort_scheme.reverse_visit(less, offset + more, visitor)
        @sort_scheme.reverse_visit(less, offset, visitor)
      end
    end

  end
end
