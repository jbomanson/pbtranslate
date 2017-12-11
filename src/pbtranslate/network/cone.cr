require "../gate"
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

  def host(visitor) : Nil
    if @is_pending
      host_and_compute(visitor, visitor.way)
    else
      host_and_pass(visitor)
    end
  end

  private def host_and_compute(visitor, way : Forward) : Nil
    host_and_compute(Visitor::Noop::INSTANCE.going(BACKWARD), BACKWARD)
    host_and_pass(visitor)
  end

  private def host_and_compute(visitor, way : Backward) : Nil
    ComputingGuide.guide(visitor, @network, @timestamps)
    @is_pending = false
  end

  private def host_and_pass(visitor) : Nil
    PassingGuide.guide(visitor, @network, @timestamps)
  end

  private class ComputingGuide(V)
    include Gate::Restriction
    include Visitor
    include Visitor::DefaultMethods
    include Visitor::OfNoYieldedContent

    # A visitor that propagates a cone through gates backward from output to
    # input wires while guiding another visitor through the network.

    def self.guide(visitor, network, timestamps) : Nil
      Util.restrict(visitor.way, Backward)
      guide = self.new(visitor, timestamps)
      network.host(guide)
      guide.finish
    end

    protected def initialize(@visitor : V, @timestamps : Array(Timestamp?))
      @reverse_index = Timestamp.zero.as(Timestamp)
    end

    def visit_gate(g : Gate(_, InPlace, _), **options) : Nil
      @reverse_index += 1
      return unless visit_gate_with_cone(g, **options)
      input_wires = g.wires
      input_wires.each do |wire|
        @timestamps[wire] ||= @reverse_index
      end
    end

    def way : Way
      BACKWARD
    end

    private def visit_gate_with_cone(g, **options) : Bool
      output_wires = g.wires
      output_cone =
        @timestamps.values_at(*output_wires).map do |timestamp|
          timestamp || false
        end
      @visitor.visit_gate(g, **options, output_cone: output_cone)
      output_cone.any?
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

    def self.guide(visitor, network, timestamps) : Nil
      Util.restrict(visitor.way, Forward)
      guide = self.new(visitor, timestamps)
      network.host(guide)
    end

    def initialize(@visitor : V, @timestamps : Array(Timestamp?))
      @index = Timestamp.zero.as(Timestamp)
    end

    def visit_gate(g : Gate(_, InPlace, _), **options) : Nil
      output_wires = g.wires
      output_cone =
        @timestamps.values_at(*output_wires).map do |timestamp|
          (timestamp && @index < timestamp) || false
        end
      @visitor.visit_gate(g, **options, output_cone: output_cone)
      @index += 1
    end
  end
end
