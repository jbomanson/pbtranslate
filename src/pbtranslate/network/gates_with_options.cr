require "../visitor"
require "../visitor/default_methods"

module PBTranslate::Network
  # Returns the gates and their options in this network as an enumerable
  # of tuples.
  def gates_with_options : Enumerable
    GatesWithOptions(typeof(self), typeof(gate_with_options_for_typeof)).new(self)
  end

  private struct GatesWithOptions(N, T)
    include Enumerable(T)

    def initialize(@network : N)
    end

    def each(&block : T -> _) : Nil
      @network.host(ProcVisitor.new(block))
    end

    private struct ProcVisitor(P)
      include Visitor
      include Visitor::DefaultMethods

      def initialize(@block : P)
      end

      def visit_gate(gate, memo, **options)
        call(gate, options, @block)
        memo
      end

      private def call(gate, options, block : T -> _) forall T
        block.call({gate, options}.as(T))
      end
    end
  end
end
