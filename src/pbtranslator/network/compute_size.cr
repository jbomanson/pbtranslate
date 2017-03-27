require "../visitor/default_methods"

module PBTranslator::Network
  # Computes the size of a network in gates by visiting all of them.
  def self.compute_size(network n, *, way y : Way = FORWARD) : Area
    ComputeSizeVisitor.compute(n, y)
  end

  private class ComputeSizeVisitor
    include Visitor::DefaultMethods

    def self.compute(network n, way y : Way)
      v = self.new
      n.host(v, y)
      v.size
    end

    getter size = Area.new(0)

    def visit_gate(g, **options) : Nil
      @size += 1
    end
  end
end
