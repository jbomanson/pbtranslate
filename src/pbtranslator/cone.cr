# A module for computing and making use of "cones of influence".
#
# Given a subset of the output wires of a network, we may determine which
# output wires of gates do they depend on.
#  We call the part of the network determined in this way a cone of influence.
#
# A module method `.visit` computes this cone.
module PBTranslator::Cone

  # :nodoc:
  class BackwardVisitor(I)
    # A visitor for determining which gate outputs are _wanted_ based on
    # which network outputs are wanted.
    #
    # The visits are intended to take place in reverse order.

    private def initialize(@levels : Array(I?))
      @reverse_index = I.new(0)
    end

    # Creates a visitor to propagate given *wanted* network outputs backward.
    def initialize(wanted)
      initialize(wanted.map {|b| b ? I.new(0) : nil})
    end

    # Propagates a cone through a gate backwards from its output to input
    # wires.
    def reverse_visit(gate) : Void
      @reverse_index += 1
      return if gate.output_wires.none? {|wire| @levels[wire]}
      gate.input_wires.each do |wire|
        @levels[wire] ||= @reverse_index
      end
    end

    private def finish : Array(I?)
      last = @reverse_index
      @levels.map! do |value|
        value && last - value
      end
    end

    def turn_around(sub_visitor)
      ForwardVisitor.new(sub_visitor, finish)
    end

  end

  # A gate enhanced with an `#output_cone` method.
  struct Gate(T, W)

    # A tuple of booleans telling which output wires are wanted and which are
    # not.
    # This is computed based on `#output_wires`.
    getter output_cone

    protected def initialize(@sub_gate : T, @output_cone : W)
    end

    # Forwards all calls to the wrapped gate.
    forward_missing_to @sub_gate

    # NOTE: This struct could alternatively be implemented by wrapping the
    # @levels and @index of ForwardVisitor and computing the cone here.
    # Then it would be economical to provide an `#input_cone` method as well.

  end

  # :nodoc:
  struct ForwardVisitor(V, I)
    # A visitor for wrapping another visitor and providing it with information
    # on which gate outputs are wanted.
    #
    # The information is expected to have been gathered with `BackwardVisitor`.

    @index = I.new(0)

    def initialize(@sub_visitor : V, @levels : Array(I?))
    end

    def visit(gate) : Void
      output_cone =
        @levels.values_at(*gate.output_wires).map do |wire|
          wire ? @index < wire : false
        end
      @sub_visitor.visit(Gate.new(gate, output_cone))
      @index += 1
    end

  end

  # Visits a *network* with *visitor* while indicating which gate
  # outputs are wanted and which are not.
  #
  # The wanted gate outputs are determined based on given *wanted* output
  # wires.
  #
  # The method visitor.visit is called with a gate argument of type
  # `Gate`.
  def self.visit(*, network, visitor, wanted)
    backward_visitor = BackwardVisitor(Int32).new(wanted)
    network.reverse_visit(backward_visitor)
    forward_visitor = backward_visitor.turn_around(visitor)
    network.visit(forward_visitor)
  end

end