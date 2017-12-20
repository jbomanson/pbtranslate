require "./gate"
require "./network"
require "./scheme"
require "./visitor/default_methods"
require "./visitor/of_no_yielded_content"

module PBTranslate::LevelTracking
  class Scheme(S)
    include PBTranslate::Scheme

    delegate_scheme_details_to @scheme
    delegate_and_declare_gate_options @scheme, level

    def initialize(@scheme : S)
      (scheme.gate_option_keys & CompileTimeSet.create(level)).empty!
    end

    def network(width w : Width)
      Network.new(network: @scheme.network(w), width: w.value)
    end

    def network?(width w : Width)
      @scheme.network?(w).try { |n| Network.new(network: n, width: w.value) }
    end
  end

  struct Network(N)
    include PBTranslate::Network

    delegate network_depth, network_read_count, network_width, network_write_count, wire_pairs, to: @network

    def initialize(*, @network : N, @width : Distance)
    end

    def host_reduce(visitor v, memo)
      d = initial_level(v.way)
      g = Guide.new(visitor: v, width: @width, initial_level: d)
      @network.host_reduce(g, memo)
    end

    private def initial_level(way : Forward)
      Distance.new(0)
    end

    private def initial_level(way : Backward)
      {{ raise "Not yet tested" }}
    end
  end

  # A visitor guide that computes the levels in a network.
  #
  # The level of a gate refers to the distance to the input furthest from it.
  # Here distance is counted in terms of gates properly between them, so that
  # the destination gate is excluded from the count.
  #
  # ### Example
  #
  #     include PBTranslate
  #
  #     struct MyVisitor
  #       include Visitor
  #
  #       def visit_gate(gate, memo, *empty_args, level)
  #         puts "#{gate.wires} @ #{level}"
  #       end
  #     end
  #
  #     a = [{0, 1}, {2, 3}, {0, 2}, {1, 3}, {1, 2}]
  #     network = Network::FlexibleIndexableComparator.new(a)
  #     width = network.width # => 4
  #     visitor = MyVisitor.new
  #     wrapper = LevelTracking::Guide.new(width: width, visitor: visitor)
  #     network.host(wrapper)
  #
  #     # Output
  #     #
  #     # {0, 1} @ 0
  #     # {2, 3} @ 0
  #     # {0, 2} @ 1
  #     # {1, 3} @ 1
  #     # {1, 2} @ 2
  class Guide(V)
    include Gate::Restriction
    include Visitor
    include Visitor::DefaultMethods
    include Visitor::OfNoYieldedContent

    delegate way, to: @visitor

    # Wraps a _visitor_ in preparation for a visit to a network of given _width_.
    def initialize(*, @visitor : V = PBTranslate::Visitor::Noop::INSTANCE, width w : Int, initial_level d = Distance.zero)
      @array = Array(Distance).new(w, Distance.new(d))
    end

    # Guides the wrapped visitor through a visit to a _gate_ and provides an
    # additional parameter _level_.
    def visit_gate(gate : Gate(_, InPlace, _), memo, **options)
      input_wires = gate.wires
      level = @array.values_at(*input_wires).max
      level += way.first(0, -1)
      memo = @visitor.visit_gate(gate, memo, **options, level: level)
      level += way.first(+1, 0)
      output_wires = gate.wires
      output_wires.each do |index|
        @array[index] = level
      end
      memo
    end
  end
end
