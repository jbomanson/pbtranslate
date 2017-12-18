require "../network"
require "../visitor/default_methods"
require "../visitor/going"

module PBTranslate::Network
  # Computes the number of gates in a network by visiting all of them.
  def self.compute_gate_count(network n, *, way y : Way = FORWARD) : Area
    ComputeGateCountVisitor.compute(n, y)
  end

  private class ComputeGateCountVisitor
    include Visitor
    include Visitor::DefaultMethods

    def self.compute(network n, way y : Way) : Area
      n.host_reduce(new.going(y), Area.new(0))
    end

    def visit_gate(gate, memo, **options)
      memo += 1
    end
  end
end
