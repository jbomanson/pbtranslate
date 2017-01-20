require "bit_array"

require "../../spec_helper"

include PBTranslator

class ArrayConeSwap(T)
  include Gate::Restriction

  getter cone_size

  @cone_size = 0

  def initialize(@array : Array(T), way : Forward)
  end

  def visit_gate(g : Gate(Comparator, InPlace, _), **options, output_cone) : Nil
    i, j = g.wires
    x, y = output_cone
    a = @array[i]
    b = @array[j]
    c = a < b
    @array[i] = c ? a : b if x
    @array[j] = c ? b : a if y
    @cone_size += output_cone.count &.itself
  end

  def visit_gate(g : Gate(Passthrough, _, _), **options) : Nil
  end
end

# Hosts a visitor through a network with a cone and returns the size of the cone
private def host_with_cone(width_log2, wanted, array) : Int32
  scheme =
    Scheme::MergeSort::Recursive.new(
      Scheme::OEMerge::INSTANCE
    )
  w = Width.from_log2(width_log2)
  n = scheme.network(w)
  nn = Network::Cone.new(network: n, width: w.value, output: wanted)
  visitor = ArrayConeSwap.new(array, FORWARD)
  nn.host(visitor, FORWARD)
  visitor.cone_size
end

# Evaluates given wanted outputs of a network with random input values.
#
# Returns
# - the size of the cone in terms of gate output wires
# - an array of computed wanted outputs
# - an array of expected wanted outputs.
private def compute(random, width_log2, wanted)
  width = 1 << width_log2
  a = Array.new(width) { random.rand }
  b = a.clone
  c = a.sort
  s = host_with_cone(width_log2, wanted, b)
  x, y =
    {b, c}.map do |array|
      index = 0
      array.select do
        wanted[index].tap do
          index += 1
        end
      end
    end
  {s, x, y}
end

describe Network::Cone do
  it "works with universally unwanted outputs and merge sorting networks" do
    random = Random.new(SEED)
    (Distance.new(0)..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      wanted = BitArray.new(width, false)
      size, computed, expected = compute(random, width_log2, wanted)
      size.should eq(0)
    end
  end

  it "works with universally wanted outputs and merge sorting networks" do
    random = Random.new(SEED)
    (Distance.new(0)..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      wanted = BitArray.new(width, true)
      size, computed, expected = compute(random, width_log2, wanted)
      computed.should eq(expected)
    end
  end

  it "works with single outputs and merge sorting networks" do
    random = Random.new(SEED)
    (Distance.new(1)..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2

      wanted_one = BitArray.new(width)
      wanted_one[random.rand(width)] = true
      size_one, computed_one, expected_one =
        compute(random, width_log2, wanted_one)

      computed_one.should eq(expected_one)

      wanted_all = BitArray.new(width, true)
      size_all, computed_all, expected_all =
        compute(random, width_log2, wanted_all)

      size_one.should be < size_all
    end
  end
end
