require "../scheme/merge_sort"
require "../scheme/oe_merge"

module PBTranslator
  class Network::MergeSort(S, M, I)
    def initialize(@sort_scheme : S, @merge_scheme : M, @width_log2 : I)
    end

    # :nodoc:
    macro three_cases(zero, one_call, else_expr)
      less = @width_log2 - 1
      case @width_log2
      when I.new(0)
        {{zero}}
      when I.new(1)
        @merge_scheme.network(less).{{one_call}}
      else
        {{else_expr}}
      end
    end

    def size
      three_cases(
        I.new(0),
        size,
        @sort_scheme.network(less).size * 2 + @merge_scheme.network(less).size,
      )
    end

    def depth
      three_cases(
        I.new(0),
        depth,
        @sort_scheme.network(less).depth + @merge_scheme.network(less).depth,
      )
    end

    private def helper_visit(*args) : Void
      three_cases(
        nil,
        visit(*args),
        yield less, I.new(1) << less, @sort_scheme.network(less)
      )
    end

    private def reverse_helper_visit(*args) : Void
      three_cases(
        nil,
        reverse_visit(*args),
        yield less, I.new(1) << less, @sort_scheme.network(less)
      )
    end

    def visit(visitor, offset = I.new(0))
      helper_visit(visitor, offset) do |less, more, sort_network|
        sort_network.visit(visitor, offset)
        sort_network.visit(visitor, offset + more)
        @merge_scheme.network(less).visit(visitor, offset)
      end
    end

    def reverse_visit(visitor, offset = I.new(0))
      reverse_helper_visit(visitor, offset) do |less, more, sort_network|
        @merge_scheme.network(less).reverse_visit(visitor, offset)
        sort_network.reverse_visit(visitor, offset + more)
        sort_network.reverse_visit(visitor, offset)
      end
    end
  end
end
