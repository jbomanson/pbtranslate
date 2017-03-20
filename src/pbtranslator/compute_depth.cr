require "./gate_options"
require "./visitor/default_methods"

module PBTranslator::Network
    # Computes the depth of this network, which is assumed to provide gate depths.
  def self.compute_depth(network n, way y : Way = FORWARD) : Distance
    ComputeDepthVisitor.compute(n, y)
  end

  private class ComputeDepthVisitor
    include Visitor::DefaultMethods

    def self.compute(network n, way y : Way) : Distance
      v = ComputeDepthVisitor.new
      n.host(v, FORWARD)
      v.depth + 1
    end

    getter depth : Distance = Distance.new(0)

    def initialize
    end

    def visit_gate(gate, *, **options, depth) : Nil
      @depth = {@depth, depth}.max
    end
  end
end

module PBTranslator::GateOptions::Module
  # Computes the depth of a network from this scheme.
  def compute_depth(width, *args) : Distance
    Network.compute_depth(with_depth.network(width), *args)
  end
end
