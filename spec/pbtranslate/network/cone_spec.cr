require "bit_array"

require "../../bidirectional_host_helper"
require "../../spec_helper"

include PBTranslate

seed = SpecHelper.file_specific_seed

private class ArrayConeSwap(T)
  include Gate::Restriction
  include Visitor

  getter cone_size

  @cone_size = 0

  def initialize(@array : Array(T), way : Forward)
  end

  def visit_gate(gate : Gate(Comparator, InPlace, _), memo, *, output_cone, **options)
    i, j = gate.wires
    x, y = output_cone
    a = @array[i]
    b = @array[j]
    c = a < b
    @array[i] = c ? a : b if x
    @array[j] = c ? b : a if y
    @cone_size += output_cone.count &.itself
    memo
  end

  def visit_gate(gate : Gate(Passthrough, _, _), memo, **options)
    memo
  end
end

# Returns a `Network::Cone` instance for testing.
private def create_cone_network(width_log2, wanted) : Network::Cone
  width = Width.from_log2(width_log2)
  Network::Cone.new(
    network: SpecHelper.pw2_sort_odd_even.network(width),
    width: width.value,
    output: wanted,
  )
end

# Hosts a visitor through a network with a cone and returns the size of the cone
private def host_with_cone(width_log2, wanted, array) : Int32
  visitor = ArrayConeSwap.new(array, FORWARD)
  create_cone_network(width_log2, wanted).host(visitor)
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
    random = Random.new(seed)
    (Distance.new(0)..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      wanted = BitArray.new(width, false)
      size, computed, expected = compute(random, width_log2, wanted)
      size.should eq(0)
    end
  end

  it "works with universally wanted outputs and merge sorting networks" do
    random = Random.new(seed)
    (Distance.new(0)..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      wanted = BitArray.new(width, true)
      size, computed, expected = compute(random, width_log2, wanted)
      computed.should eq(expected)
    end
  end

  it "works with single outputs and merge sorting networks" do
    random = Random.new(seed)
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

  BidirectionalHostHelper.it_works_predictably_in_reverse ->{
    random = Random.new(seed)
    width_log2 = Distance.new(2)
    width = 1 << width_log2
    wanted_one = BitArray.new(width)
    wanted_one[random.rand(width)] = true
    create_cone_network(width_log2, wanted_one)
  }
end
