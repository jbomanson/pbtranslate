require "./gate"
require "./scheme"
require "./visitor/default_methods"
require "./visitor/of_no_yielded_content"

module PBTranslator::DepthTracking
  class Scheme(S)
    include PBTranslator::Scheme

    delegate_and_declare_gate_options @scheme, depth

    def initialize(@scheme : S)
      scheme.gate_options.restrict(depth: nil)
    end

    def network(width w : Width)
      Network.new(network: @scheme.network(w), width: w.value)
    end

    def network?(width w : Width)
      @scheme.network?(w).try { |n| Network.new(network: n, width: w.value) }
    end
  end

  struct Network(N)
    delegate network_depth, network_read_count, network_width, network_write_count, wire_pairs, to: @network

    def initialize(*, @network : N, @width : Distance)
    end

    def host(visitor v, way y : Way) : Nil
      d = initial_depth(y)
      g = Guide.new(visitor: v, way: y, width: @width, initial_depth: d)
      @network.host(g, y)
    end

    private def initial_depth(way : Forward)
      Distance.new(0)
    end

    private def initial_depth(way : Backward)
      {{ raise "Not yet tested" }}
    end
  end
  
  # A visitor guide that computes the depths in a network.
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
  #       def visit_gate(g, *args, depth) : Nil
  #         puts "#{g.wires} @ #{depth}"
  #       end
  #     end
  #
  #     a = [{0, 1}, {2, 3}, {0, 2}, {1, 3}, {1, 2}]
  #     network = Network::IndexableComparator.new(a)
  #     width = network.width # => 4
  #     visitor = MyVisitor.new
  #     wrapper = DepthTracking::Guide.new(width: width, visitor: visitor)
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
  class Guide(V, W)
    include Gate::Restriction
    include Visitor::DefaultMethods
    include Visitor::OfNoYieldedContent

    # Computes the depth of the network seen so far.
    getter depth

    # Wraps a _visitor_ in preparation for a visit to a network of given _width_.
    def initialize(*, @visitor : V = PBTranslator::Visitor::Noop::INSTANCE, way : W, width w : Int, initial_depth d = Distance.zero)
      @array = Array(Distance).new(w, Distance.new(d))
      @depth = Distance.zero
    end

    # Guides the wrapped visitor through a visit to a _gate_ and provides an
    # additional parameter _depth_.
    def visit_gate(g : Gate(_, InPlace, _), *args, **options) : Nil
      input_wires = g.wires
      depth = @array.values_at(*input_wires).max
      depth += W.new.first(0, -1)
      @visitor.visit_gate(g, *args, **options, depth: depth)
      depth += W.new.first(+1, 0)
      @depth = {@depth, depth}.max
      output_wires = g.wires
      output_wires.each do |index|
        @array[index] = depth
      end
    end
  end
end
