require "../network"
require "../visitor/default_methods"
require "../visitor/going"

module PBTranslate::Network
  # Computes the sum of the results returned by a block that is called over the
  # numbers of wires and the names of the +F+ classes of the `Gate`s in a
  # network.
  def reduce_gate_feature(memo : T, &block : T, Int32, String -> T) : T forall T
    ReduceGateFeatureVisitor.compute(self, memo, block)
  end

  private struct ReduceGateFeatureVisitor(T)
    include Visitor
    include Visitor::DefaultMethods

    def initialize(@block : T, Int32, String -> T)
    end

    def self.compute(network, memo : T, block) : T
      network.host_reduce(new(block), memo)
    end

    def visit_gate(gate, memo : T, **options)
      reduce(memo, gate)
    end

    private def reduce(memo : T, gate : Gate(F, _, _)) : T forall F
      @block.call(memo, gate.wires.size, F.name)
    end

    private def reduce(memo) : T
      memo
    end
  end
end
