require "../gate"

# A network with weights on wires obtained by propagating given initial weights
# through another network.
class PBTranslator::Network::WireWeighted(N, I)
  # Enhances a _network_ with _weights_ propagated through its gates.
  def initialize(*, @network : N, @weights : Array(I))
  end

  # Hosts a visit to the underlying network and to propagated weights.
  #
  # The weights are provided to _visitor_ by calling its _visit_ method with
  # named parameters _weight_ and _wire_.
  # The sum of visited wire weights equals the sum of the initial weights.
  def host(visitor v, way y : Way) : Nil
    PropagatingGuide.guide(@network, @weights, v, y)
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

    def visit_gate(g : Gate(Comparator, InPlace, _), **options) : Nil
      o = propagate_weights_at(g.wires)
      @visitor.visit_gate(g, **options, input_weights: o)
    end

    def visit_gate(g : Gate(Passthrough, _, _), **options) : Nil
      @visitor.visit_gate(g, **options, input_weights: g.wires.map { I.zero })
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
        @visitor.visit_gate(Gate.passthrough_at(wire), input_weights: {weight})
      end
    end
  end
end
