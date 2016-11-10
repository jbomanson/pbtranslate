# A visitor wrapper or a guide that computes the depths in a network.
#
# The depth of a gate refers to the distance to the input furthest from it.
# Here distance is counted in terms of gates properly between them, so that
# the destination gate is excluded from the count.
# The depth of an entire network is the longest distance between an input and
# an output.
#
# Example:
#
#     struct Network
#       include Gate::Restriction
#
#       def initialize(@wire_pairs : Array(Tuple(Int32, Int32)))
#       end
#
#       def width
#         @wire_pairs.map(&.max).max + 1
#       end
#
#       def host(visitor, *args) : Void
#         @wire_pairs.each do |pair|
#           visitor.visit(Gate.comparator_between(*pair), *args)
#         end
#       end
#     end
#
#     struct MyVisitor
#       def visit(gate, *args, depth)
#         puts "#{gate.wires} @ #{depth}"
#       end
#     end
#
#     a = [{0, 1}, {2, 3}, {0, 2}, {1, 3}, {2, 3}]
#     network = Network.new(a)
#     width = network.width # => 4
#     visitor = MyVisitor.new
#     wrapper = Visitor::ArrayDepth.new(width: width, visitor: visitor)
#     network.host(wrapper, FORWARD)
#     wrapper.depth # => 3
#
#     # Output
#     #
#     # {0, 1} @ 0
#     # {2, 3} @ 0
#     # {0, 2} @ 1
#     # {1, 3} @ 1
#     # {2, 3} @ 2
struct PBTranslator::Visitor::ArrayDepth(V)
  include Gate::Restriction

  # Creates an ArrayDepth visitor without a meaningful wrapped visitor.
  # This is useful if only the depth of a network is of interest.
  #
  # Example:
  #     visitor = Visitor::ArrayDepth.new(width: width)
  #     network.host(visitor, FORWARD)
  #     visitor.depth
  def self.new(*, width)
    new(width: width, visitor: Noop::INSTANCE)
  end

  # Wraps a _visitor_ in preparation for a visit to a network of given _width_.
  def initialize(*, width, @visitor : V)
    @array = Array(UInt32).new(width, 0_u32)
  end

  # Guides the wrapped visitor through a visit to a _gate_ and provides an
  # additional named parameter _depth_.
  def visit(gate : Gate(_, InPlace, _), *args, **options) : Void
    input_wires = gate.wires
    depth = @array.values_at(*input_wires).max
    @visitor.visit(gate, *args, **options, depth: depth)
    depth += 1
    output_wires = gate.wires
    output_wires.each do |index|
      @array[index] = depth
    end
  end

  # Computes the depth of the network seen so far.
  def depth
    @array.max
  end
end
