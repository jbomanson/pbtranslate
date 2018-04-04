require "../gate"
require "../network"
require "../visitor/default_methods"
require "../visitor/of_no_yielded_content"

# A network with weights on wires obtained by propagating given initial weights
# through another network.
#
# Works forward only.
class PBTranslate::Network::WireWeighted(N, W)
  include Network

  # Enhances a _network_ with _weights_ propagated through its gates.
  def initialize(*, @network : N, @weights : Array(W))
  end

  # Hosts a visit to the underlying network and to propagated weights.
  # Returns the depth of this network that is the depth of the wrapped network
  # plus one.
  def network_depth
    @network.network_depth + 1
  end

  #
  # The weights are provided to _visitor_ by calling its _visit_ method with
  # named parameters _weight_ and _wire_.
  # The sum of visited wire weights equals the sum of the initial weights.
  def host_reduce(visitor, memo)
    PropagatingGuide.guide(@network, @weights, visitor, memo)
  end

  private struct PropagatingGuide(V, W)
    include Visitor
    include Gate::Restriction
    include Visitor::DefaultMethods
    include Visitor::OfNoYieldedContent

    def self.guide(network, weights, visitor, memo)
      network.gate_option_keys.superset! CompileTimeSet.create(:level)
      Util.restrict(visitor.way, Forward)
      propagator = new(visitor: visitor, weights: weights)
      memo = network.host_reduce(propagator, {depth: Distance.new(0), user_memo: memo})
      memo = propagator.sweep(memo)
      memo
    end

    protected def initialize(*, @visitor : V, @weights : Array(W))
    end

    def visit_gate(gate, memo, **options)
      {
        depth:     {memo[:depth], options[:level] + 1}.max,
        user_memo: @visitor.visit_gate(
          gate,
          memo[:user_memo],
          **options,
          input_weights: propagate_weights_at(gate.wires, gate.function)
        ),
      }
    end

    private def propagate_weights_at(wires, gate_function : Comparator)
      weights = @weights
      wire_weights = wires.map { |wire| weights[wire] }
      least = wire_weights.min
      wires.each { |wire| weights[wire] = least }
      wire_weights.map { |weight| weight - least }
    end

    private def propagate_weights_at(wires, gate_function : Passthrough)
      wires.map { W.zero }
    end

    protected def sweep(memo)
      level = memo[:depth]
      user_memo = memo[:user_memo]
      @weights.each_with_index do |weight, index|
        user_memo = @visitor.visit_gate(
          Gate.passthrough_at(Distance.new(index)),
          user_memo,
          level: level,
          input_weights: {weight},
        )
      end
      user_memo
    end
  end
end
