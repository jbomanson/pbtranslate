require "../gate"
require "../network"
require "../visitor/default_methods"
require "../visitor/of_no_yielded_content"

# A network that computes a _cone of influence_ for another network on the fly.
#
# Each gate output in a network influences some subset of network outputs.
# Put otherwise, each output of a network is influenced by some subset of gate
# outputs. We say that the gate outputs that influence a set of network outputs
# form a cone of influence.
#
# There is no corresponding default scheme.

class PBTranslate::Network::Cone(N)
  include Network

  private alias Timestamp = Area

  @timestamps : Array(Timestamp?)

  # Creates a version of a _network_ that augments visits with a named parameter
  # *output_cone*.
  #
  # The output_cone parameter is a tuple of booleans indicating which outputs
  # are in the cone.
  # The cone is computed based on network outputs for which _output.[]_ returns
  # true.
  def self.new(*args, output, **options)
    new(*args, **options) { |i| output[i] }
  end

  # Like the other `new` but using a block for picking network outputs.
  def initialize(*, @network : N, width, &block : Int32 -> Bool)
    @timestamps = Array.new(width) { |index| (yield index) ? Timestamp.zero : nil }
    @is_pending = true
  end

  def host_reduce(visitor, memo)
    if @is_pending
      host_reduce_and_compute(visitor, memo, visitor.way)
    else
      host_reduce_and_pass(visitor, memo)
    end
  end

  private def host_reduce_and_compute(visitor, memo, way : Forward)
    memo = host_reduce_and_compute(Visitor::Noop::INSTANCE.going(BACKWARD), memo, BACKWARD)
    memo = host_reduce_and_pass(visitor, memo)
    memo
  end

  private def host_reduce_and_compute(visitor, memo, way : Backward)
    @is_pending = false
    ComputingGuide.guide(visitor, memo, @network, @timestamps)
  end

  private def host_reduce_and_pass(visitor, memo)
    PassingGuide.guide(visitor, memo, @network, @timestamps)
  end

  private class ComputingGuide(V)
    include Gate::Restriction
    include Visitor
    include Visitor::DefaultMethods
    include Visitor::OfNoYieldedContent

    # A visitor that propagates a cone through gates backward from output to
    # input wires while guiding another visitor through the network.

    def self.guide(visitor, memo, network, timestamps)
      Util.restrict(visitor.way, Backward)
      guide = new(visitor, timestamps)
      memo = network.host_reduce(guide, memo)
      guide.finish
      memo
    end

    protected def initialize(@visitor : V, @timestamps : Array(Timestamp?))
      @reverse_index = Timestamp.zero.as(Timestamp)
    end

    def visit_gate(gate : Gate(_, InPlace, _), memo, **options)
      @reverse_index += 1
      any, memo = visit_gate_with_cone(gate, memo, **options)
      if any
        input_wires = gate.wires
        input_wires.each do |wire|
          @timestamps[wire] ||= @reverse_index
        end
      end
      memo
    end

    def way : Way
      BACKWARD
    end

    private def visit_gate_with_cone(gate, memo, **options)
      output_wires = gate.wires
      output_cone =
        @timestamps.values_at(*output_wires).map do |timestamp|
          timestamp || false
        end
      {
        output_cone.any?,
        @visitor.visit_gate(gate, memo, **options, output_cone: output_cone),
      }
    end

    protected def finish : Nil
      last = @reverse_index
      @timestamps.map! do |value|
        value && last - value
      end
    end
  end

  private class PassingGuide(V)
    include Gate::Restriction
    include Visitor
    include Visitor::DefaultMethods
    include Visitor::OfNoYieldedContent

    # A visitor that guides another and indicates to it which output wires
    # are in a cone.

    def self.guide(visitor, memo, network, timestamps)
      Util.restrict(visitor.way, Forward)
      guide = new(visitor, timestamps)
      network.host_reduce(guide, memo)
    end

    def initialize(@visitor : V, @timestamps : Array(Timestamp?))
      @index = Timestamp.zero.as(Timestamp)
    end

    def visit_gate(gate : Gate(_, InPlace, _), memo, **options)
      output_wires = gate.wires
      output_cone =
        @timestamps.values_at(*output_wires).map do |timestamp|
          (timestamp && @index < timestamp) || false
        end
      @index += 1
      @visitor.visit_gate(gate, memo, **options, output_cone: output_cone)
    end
  end
end
