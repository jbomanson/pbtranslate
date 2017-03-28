require "../visitor/default_methods"

module PBTranslator::Network
  # Computes the number of gates in a network by visiting all of them.
  def self.compute_gate_count(network n, *, way y : Way = FORWARD) : Area
    ComputeGateCountVisitor.compute(n, y)
  end

  private class ComputeGateCountVisitor
    include Visitor::DefaultMethods

    def self.compute(network n, way y : Way)
      v = self.new
      n.host(v, y)
      v.count
    end

    getter count = Area.new(0)

    def visit_gate(g, **options) : Nil
      @count += 1
    end
  end
end
