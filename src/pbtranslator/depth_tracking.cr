require "./with_depth"

module PBTranslator::DepthTracking
  class Scheme(S)
    include WithDepth::Scheme

    def initialize(@scheme : S)
    end

    def network(width w : Width)
      Network.new(network: @scheme.network(w), width: w.value)
    end
  end

  struct Network(N, I)
    include WithDepth::Network

    delegate size, depth, to: @network
    getter computed_depth

    @computed_depth : UInt32 = 0_u32

    def initialize(*, @network : N, @width : I)
    end

    def host(visitor v, way y : Way) : Void
      d = initial_depth(y)
      u = Visitor.new(visitor: v, width: @width, initial_depth: d)
      @network.host(u, y)
      @computed_depth = u.depth
    end

    private def initial_depth(way : Forward)
      0
    end

    private def initial_depth(way : Backward)
      depth
    end
  end
  
  # A visitor wrapper or a guide that computes the depths in a network.
  #
  # The depth of a gate refers to the distance to the input furthest from it.
  # Here distance is counted in terms of gates properly between them, so that
  # the destination gate is excluded from the count.
  # The depth of an entire network is the longest distance between an input and
  # an output.
  #
  # ### Example
  #
  #     include PBTranslator
  #
  #     struct MyVisitor
  #       def visit(gate, *args, depth) : Void
  #         puts "#{gate.wires} @ #{depth}"
  #       end
  #     end
  #
  #     a = [{0, 1}, {2, 3}, {0, 2}, {1, 3}, {1, 2}]
  #     network = Network::IndexableComparator.new(a)
  #     width = network.width # => 4
  #     visitor = MyVisitor.new
  #     wrapper = DepthTracking::Visitor.new(width: width, visitor: visitor)
  #     network.host(wrapper, FORWARD)
  #     wrapper.depth # => 3
  #
  #     # Output
  #     #
  #     # {0, 1} @ 0
  #     # {2, 3} @ 0
  #     # {0, 2} @ 1
  #     # {1, 3} @ 1
  #     # {1, 2} @ 2
  class Visitor(V)
    include Gate::Restriction
    include WithDepth::Visitor

    # Computes the depth of the network seen so far.
    getter depth

    # Wraps a _visitor_ in preparation for a visit to a network of given _width_.
    def initialize(*, @visitor : V = PBTranslator::Visitor::Noop::INSTANCE, width w : Int, initial_depth d = 0_u32)
      @array = Array(UInt32).new(w, d.to_u32)
      @depth = 0_u32
    end

    # Guides the wrapped visitor through a visit to a _gate_ and provides an
    # additional parameter _depth_.
    def visit(gate g : Gate(_, InPlace, _), way w : Way, *args, **options) : Void
      input_wires = g.wires
      depth = @array.values_at(*input_wires).max
      depth += increment_before(w)
      @visitor.visit(g, w, *args, **options, depth: depth)
      depth += increment_after(w)
      @depth = {@depth, depth}.max
      output_wires = g.wires
      output_wires.each do |index|
        @array[index] = depth
      end
    end

    private def increment_before(way : Forward)
      0
    end

    private def increment_before(way : Backward)
      -1
    end

    private def increment_after(way : Forward)
      1
    end

    private def increment_after(way : Backward)
      0
    end
  end
end
