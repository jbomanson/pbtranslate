# A visitor that guides two other visitors through a network.
#
# See `arrange_visit`.
struct PBTranslator::Visitor::ArrayWeightPropagator(V, W, I)
  include Gate::Restriction

  # Guides two visitors through a _network_.
  #
  # A gate_visitor is guided through all the gates in the network.
  # A weight_visitor is guided through weighted wires in the mean time.
  # The weights are based on an array of initial wire _weights_, which are
  # propagated through the gates in the network.
  # The sum of visited wire weights equals the sum of the initial weights.
  def self.arrange_visit(*args, **options, gate_visitor, weight_visitor, weights, network) : Void
    p = new(gate_visitor: gate_visitor, weight_visitor: weight_visitor, weights: weights)
    p.arrange_visit(*args, **options, network: network)
  end

  protected def initialize(*, @gate_visitor : V, @weight_visitor : W, @weights : Array(I))
  end

  def visit(gate : Gate(Comparator, InPlace, _), *args, **options) : Void
    propagate_weights_at(gate.wires)
    @gate_visitor.visit(gate, *args, **options)
  end

  protected def arrange_visit(*args, **options, network) : Void
    network.host(self, *args, **options)
    @weights.each_with_index do |weight, wire|
      @weight_visitor.visit(weight: weight, wire: wire)
    end
  end

  private def propagate_weights_at(wires)
    wire_weights = wires.map { |wire| @weights[wire] }
    least = wire_weights.min
    wires.each { |wire| @weights[wire] = least }
    differences = wire_weights.map { |weight| weight - least }
    wires.each_with_index do |wire, i|
      @weight_visitor.visit(weight: differences[i], wire: wire)
    end
  end
end
