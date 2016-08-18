require "./one_way"
require "./oe_merge"

module PBTranslator

  # A MergeSort scheme implements traditional merge sorting using a scheme of
  # type *S* for sorting subsequences and the `OEMerge` scheme for merging
  # them.
  class Scheme::MergeSort(S) < Scheme::OneWay

    alias Recursive = MergeSort(Recursive)

    DEFAULT_INSTANCE = MergeSort(Recursive).new

    # :nodoc:
    MERGE_SCHEME = Scheme::OEMerge::INSTANCE

    record Network(S, I), sort_scheme : S, width_log2 : I do

      # :nodoc:
      macro three_cases(zero, one_call, else_expr)
        less = width_log2 - 1
        case width_log2
        when I.new(0)
          {{zero}}
        when I.new(1)
          MERGE_SCHEME.network(less).{{one_call}}
        else
          {{else_expr}}
        end
      end

      def size
        three_cases(
          I.new(0),
          size,
          sort_scheme.network(less).size * 2 + MERGE_SCHEME.network(less).size,
        )
      end

      def depth
        three_cases(
          I.new(0),
          depth,
          sort_scheme.network(less).depth + MERGE_SCHEME.network(less).depth,
        )
      end

      private def helper_visit(*args) : Void
        three_cases(
          nil,
          visit(*args),
          yield less, I.new(1) << less, sort_scheme.network(less)
        )
      end

      private def reverse_helper_visit(*args) : Void
        three_cases(
          nil,
          reverse_visit(*args),
          yield less, I.new(1) << less, sort_scheme.network(less)
        )
      end

      def visit(visitor, offset = I.new(0))
        helper_visit(visitor, offset) do |less, more, sort_network|
          sort_network.visit(visitor, offset)
          sort_network.visit(visitor, offset + more)
          MERGE_SCHEME.network(less).visit(visitor, offset)
        end
      end

      def reverse_visit(visitor, offset = I.new(0))
        reverse_helper_visit(visitor, offset) do |less, more, sort_network|
          MERGE_SCHEME.network(less).reverse_visit(visitor, offset)
          sort_network.reverse_visit(visitor, offset + more)
          sort_network.reverse_visit(visitor, offset)
        end
      end

    end

    @sort_scheme : S

    # Creates a MergeSort scheme that sorts subsequences using *sort_scheme*.
    def initialize(@sort_scheme : S)
    end

    # Creates a recursive MergeSort scheme.
    def initialize
      initialize(self)
    end

    def network(width_log2)
      Network.new(@sort_scheme, width_log2)
    end

  end
end
