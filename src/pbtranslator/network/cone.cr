require "../gate"

# A network that computes a _cone of influence_ for another network on-the-fly.
#
# Each gate output in a network influences some subset of network outputs.
# Put otherwise, each output of a network is influenced by some subset of gate
# outputs. We say that the gate outputs that influence a set of network outputs
# form a cone of influence.
#
# There is no corresponding default scheme.
class PBTranslator::Network::Cone(N)
  @levels : Array(Int32?)

  # Creates a version of a _network_ that provides an *output_cone* method for
  # all visited gates.
  #
  # The cone is computed based on network outputs for which _output.[]_ returns
  # true.
  def self.new(*args, **options, output)
    new(*args, **options) {|i| output[i]}
  end

  # Creates a version of a _network_ that provides an *output_cone* method for
  # all visited gates.
  #
  # The cone is computed based on network outputs for which the given block
  # returns true.
  def initialize(*, @network : N, width, &block : Int32 -> Bool)
    @levels = Array.new(width) { |index| (yield index) ? Int32.zero : nil }
    @is_pending = true
  end

  def host(visitor, way : Way, *args, **options) : Void
    if @is_pending
      host_and_compute(visitor, way, *args, **options)
    else
      host_and_pass(visitor, way, *args, **options)
    end
  end

  private def host_and_compute(visitor, way : Forward, *args, **options) : Void
    host_and_compute(Visitor::Noop::INSTANCE, BACKWARD, *args, **options)
    host_and_pass(visitor, FORWARD, *args, **options)
  end

  private def host_and_compute(visitor, way : Backward, *args, **options) : Void
    guide = ComputingGuide.new(visitor, @levels)
    @network.host(guide, way, *args, **options)
    guide.finish
    @is_pending = false
  end

  private def host_and_pass(visitor, way : Way, *args, **options) : Void
    guide = PassingGuide.new(visitor, @levels)
    @network.host(guide, way, *args, **options)
  end

  # :nodoc:
  class ComputingGuide(V, I)
    include Gate::Restriction

    # A visitor that propagates a cone through gates backward from output to
    # input wires while guiding another visitor through the network.

    def initialize(@visitor : V, @levels : Array(I?))
      @reverse_index = I.zero.as(I)
    end

    def visit(gate : Gate(_, InPlace, _), way : Backward, *args, **options) : Void
      @reverse_index += 1
      return unless visit_with_cone(gate, way, *args, **options)
      input_wires = gate.wires
      input_wires.each do |wire|
        @levels[wire] ||= @reverse_index
      end
    end

    private def visit_with_cone(gate, way, *args, **options) : Bool
      output_wires = gate.wires
      output_cone =
        @levels.values_at(*output_wires).map do |wire|
          wire ? true : false
        end
      @visitor.visit(Wires.wrap(gate, output_cone), way, *args, **options)
      output_cone.any?
    end

    def finish : Void
      last = @reverse_index
      @levels.map! do |value|
        value && last - value
      end
    end
  end

  # :nodoc:
  struct PassingGuide(V, I)
    include Gate::Restriction

    # A visitor that guides another and indicates to it which output wires
    # are in a cone.

    def initialize(@visitor : V, @levels : Array(I?))
      @index = I.zero.as(I)
    end

    def visit(gate : Gate(_, InPlace, _), way : Forward, *args, **options) : Void
      output_wires = gate.wires
      output_cone =
        @levels.values_at(*output_wires).map do |wire|
          wire ? @index < wire : false
        end
      @visitor.visit(Wires.wrap(gate, output_cone), way, *args, **options)
      @index += 1
    end
  end

  # A wire tuple enhanced with an `#output_cone` method.
  struct Wires(T, C)
    def self.wrap(gate : Gate(F, S, T), output_cone)
      Gate(F, S, Wires(T, typeof(output_cone))).new(Wires.new(gate.wires, output_cone))
    end

    # A tuple of booleans indicating the output wires in a cone of influence.
    #
    # This is computed based on `#output_wires`.
    getter output_cone

    protected def initialize(@wires : T, @output_cone : C)
    end

    # Forwards all calls to the wrapped wires.
    forward_missing_to @wires
  end
end
