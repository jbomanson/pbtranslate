require "../gate"

# A network with weights on wires obtained by propagating given initial weights
# through another network.
class PBTranslator::Network::WireWeighted(N, I)
  def self.pair(*, gate_visitor g = Visitor::Noop, weight_visitor w = Visitor::Noop)
    VisitorPair.new(gate_visitor: g, weight_visitor: w)
  end

  # Enhances a _network_ with _weights_ propagated through its gates.
  def initialize(*, @network : N, @weights : Array(I))
  end

  # Hosts a visit to the underlying network and to propagated weights.
  #
  # The weights are provided to _visitor_ by calling its _visit_ method with
  # named parameters _weight_ and _wire_.
  # The sum of visited wire weights equals the sum of the initial weights.
  def host(visitor v, way y : Way) : Void
    PropagatingGuide.guide(@network, @weights, v, y)
  end

  private struct VisitorPair(G, W)
    def initialize(*, @gate_visitor : G, @weight_visitor : W)
    end

    def visit_gate(g, **options, output_weights) : Void
      @gate_visitor.visit_gate(g, **options)
      g.wires.zip(output_weights) do |wire, weight|
        @weight_visitor.visit_weighted_wire(weight: weight, wire: wire)
      end
    end

    def visit_region(region) : Void
      @gate_visitor.visit_region(region) do |region_visitor|
        yield self.class.new(
          gate_visitor: region_visitor,
          weight_visitor: @weight_visitor)
      end
    end
  end

  private struct PropagatingGuide(V, I)
    include Gate::Restriction

    def self.guide(network n, weights w, visitor v, way : Forward)
      p = self.new(visitor: v, weights: w)
      n.host(p, FORWARD)
      p.sweep
    end

    protected def initialize(*, @visitor : V, @weights : Array(I))
    end

    def visit_gate(g : Gate(Comparator, InPlace, _), **options) : Void
      o = propagate_weights_at(g.wires)
      @visitor.visit_gate(g, **options, output_weights: o)
    end

    def visit_gate(g : Gate(Passthrough, _, _), **options) : Void
      @visitor.visit_gate(g, **options, output_weights: g.wires.map { I.zero })
    end

    private def propagate_weights_at(wires)
      weights = @weights
      wire_weights = wires.map { |wire| weights[wire] }
      least = wire_weights.min
      wires.each { |wire| weights[wire] = least }
      wire_weights.map { |weight| weight - least }
    end

    protected def sweep
      @weights.each_with_index do |weight, wire|
        @visitor.visit_gate(Gate.passthrough_at(wire), output_weights: {weight})
      end
    end
  end
end
