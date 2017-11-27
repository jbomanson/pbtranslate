require "./scheme"
require "./visitor/default_methods"

module PBTranslate::Network
  # Computes the depth of a network, which must already provide gate depths, by
  # finding the maximum depth of its gates and adding one to it.
  def self.compute_depth(network n) : Distance
    ComputeDepthVisitor.compute(n)
  end

  private class ComputeDepthVisitor
    include Visitor
    include Visitor::DefaultMethods

    def self.compute(network n) : Distance
      v = ComputeDepthVisitor.new
      n.host(v)
      v.result
    end

    @depth = Distance::MIN
    @bonus = Distance.new(0)

    protected def result
      @depth + @bonus
    end

    def visit_gate(gate, *, **options, depth) : Nil
      @depth = {@depth, depth}.max
      @bonus = Distance.new(1)
    end
  end
end

module PBTranslate::Scheme
  # Computes the depth of a network from this scheme.
  def compute_depth(width, *args) : Distance
    Network.compute_depth(with_gate_depth.network(width), *args)
  end
end
