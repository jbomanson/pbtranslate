require "./scheme"
require "./visitor/default_methods"

module PBTranslate::Network
  # Computes the depth of a network, which must already provide gate levels, by
  # finding the maximum depth of its gates and adding one to it.
  def self.compute_depth(network n) : Distance
    ComputeDepthVisitor.compute(n)
  end

  private class ComputeDepthVisitor
    include Visitor
    include Visitor::DefaultMethods

    record Memo, depth = Distance::MIN, bonus = Distance.new(0) do
      def sum : Distance
        depth + bonus
      end

      def update(level) : self
        self.class.new({depth, level}.max, Distance.new(1))
      end
    end

    def self.compute(network n) : Distance
      n.host_reduce(ComputeDepthVisitor.new, Memo.new).sum
    end

    def visit_gate(gate, memo, *empty_args, level, **options)
      memo.update(level)
    end
  end
end

module PBTranslate::Scheme
  # Computes the depth of a network from this scheme.
  def compute_depth(width, *args) : Distance
    Network.compute_depth(to_scheme_with_gate_level.network(width), *args)
  end
end
