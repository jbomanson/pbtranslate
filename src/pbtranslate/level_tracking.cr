require "./compile_time_set"
require "./gate"
require "./level_tracking"
require "./network"
require "./scheme"
require "./visitor/default_methods"
require "./visitor/of_no_yielded_content"

module PBTranslate::Scheme
  # Converts this scheme into one that has the gate option _level_.
  def to_scheme_with_gate_level_added
    LevelTrackingScheme.new(self)
  end

  # Converts this scheme into one that has the gate option _level_, if needed.
  def to_scheme_with_gate_level
    to_scheme_with_gate_level &.to_scheme_with_gate_level_added
  end

  # Yields this scheme to a block that must return a scheme with the gate
  # option _level_, or returns this scheme as is without yielding anything if
  # this scheme already has that gate option.
  #
  # The return value of the block is statically checked to have the gate option
  # _level_.
  # In the case that this scheme is yielded to the block, it is statically
  # checked to not already have the gate option _level_.
  def to_scheme_with_gate_level
    scheme_with_level =
      to_scheme_with_gate_level_helper(gate_option_keys.to_named_tuple[:level]?) do |scheme|
        scheme.gate_option_keys.disjoint! CompileTimeSet.create(:level)
        yield scheme
      end
    scheme_with_level.gate_option_keys.superset! CompileTimeSet.create(:level)
    scheme_with_level
  end

  private def to_scheme_with_gate_level_helper(level : Nil)
    yield self
  end

  private def to_scheme_with_gate_level_helper(level, &block)
    self
  end
end

private struct LevelTrackingScheme(S)
  include PBTranslate::Scheme

  delegate_scheme_details_to @scheme

  def initialize(@scheme : S)
    scheme.gate_option_keys.disjoint! CompileTimeSet.create(:level)
  end

  def network(width : Width)
    LevelTrackingNetwork.new(@scheme.network(width), width.value)
  end

  def network?(width : Width)
    if net = @scheme.network?(width)
      LevelTrackingNetwork.new(net, width.value)
    end
  end
end

module PBTranslate::Network
  # Converts this network into one that has the gate option _level_.
  def to_network_with_gate_level
    LevelTrackingNetwork.new(self, network_width)
  end
end

private struct LevelTrackingNetwork(N)
  include PBTranslate::Network

  delegate network_depth, network_read_count, network_width, network_write_count, wire_pairs, to: @network

  def initialize(@network : N, @width : Distance)
  end

  def host_reduce(visitor, memo)
    @network.host_reduce(
      LevelTrackingGuide.new(
        visitor: visitor,
        width: @width,
        initial_level: initial_level(visitor.way),
      ),
      memo,
    )
  end

  private def initial_level(way : Forward)
    Distance.new(0)
  end

  private def initial_level(way : Backward)
    raise "Backward iteration is not supported with #to_scheme_with_gate_level"
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
#     wrapper = LevelTrackingGuide.new(width: width, visitor: visitor)
#     network.host(wrapper)
#
#     # Output
#     #
#     # {0, 1} @ 0
#     # {2, 3} @ 0
#     # {0, 2} @ 1
#     # {1, 3} @ 1
#     # {1, 2} @ 2
private class LevelTrackingGuide(V)
  include Gate::Restriction
  include Visitor
  include Visitor::DefaultMethods
  include Visitor::OfNoYieldedContent

  delegate way, to: @visitor

  getter levels : Array(Distance)

  # Wraps a _visitor_ in preparation for a visit to a network of given _width_.
  def initialize(*, @visitor : V, width : Int, initial_level d = Distance.zero)
    @levels = Array(Distance).new(width, Distance.new(d))
  end

  # Guides the wrapped visitor through a visit to a _gate_ and provides an
  # additional parameter _level_.
  def visit_gate(gate : Gate(_, InPlace, _), memo, **options)
    input_wires = gate.wires
    level = @levels.values_at(*input_wires).max
    level += way.first(0, -1)
    memo = @visitor.visit_gate(gate, memo, **options, level: level)
    level += way.first(+1, 0)
    output_wires = gate.wires
    output_wires.each do |index|
      @levels[index] = level
    end
    memo
  end
end
