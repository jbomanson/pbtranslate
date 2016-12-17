require "bit_array"

require "../../spec_helper"

include PBTranslator

record ArrayConeSwap(T), array : Array(T) do
  include Gate::Restriction

  def visit(gate : Gate(Comparator, InPlace, _), way : Forward, **options, output_cone) : Void
    i, j = gate.wires
    x, y = output_cone
    a = @array[i]
    b = @array[j]
    c = a < b
    @array[i] = c ? a : b if x
    @array[j] = c ? b : a if y
  end

  def visit(gate : Gate(Passthrough, _, _), way : Forward, **options) : Void
  end
end

record ArrayConeNot do
  include Gate::Restriction

  def visit(gate : Gate(Comparator, InPlace, _), way : Forward, **options, output_cone) : Void
    return if output_cone.none?
    raise "Expected two false booleans, got #{output_cone}"
  end

  def visit(gate : Gate(Passthrough, _, _), way : Forward, **options) : Void
  end
end

scheme =
  Scheme::MergeSort::Recursive.new(
    Scheme::OEMerge::INSTANCE
  )

private def create_network(scheme, width_log2, wanted, visitor) : Void
  w = Width.from_log2(width_log2)
  n = scheme.network(w)
  nn = Network::Cone.new(network: n, width: w.value, output: wanted)
  nn.host(visitor, FORWARD)
end

# Returns a tuple of computed and a tuple of correct wanted outputs.
private def compute(scheme, random, width_log2, wanted)
  width = 1 << width_log2
  a = Array.new(width) { random.rand }
  b = a.clone
  c = a.sort
  create_network(scheme, width_log2, wanted, ArrayConeSwap.new(b))
  {b, c}.map do |array|
    index = 0
    array.select do
      wanted[index].tap do
        index += 1
      end
    end
  end
end

describe Network::Cone do
  it "works with universally unwanted outputs and merge sorting networks" do
    random = Random.new(SEED)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      wanted = BitArray.new(width, false)
      create_network(scheme, width_log2, wanted, ArrayConeNot.new)
    end
  end

  it "works with universally wanted outputs and merge sorting networks" do
    random = Random.new(SEED)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      wanted = BitArray.new(width, true)
      wanted_b, wanted_c = compute(scheme, random, width_log2, wanted)
      wanted_b.should eq(wanted_c)
    end
  end

  it "works with single outputs and merge sorting networks" do
    random = Random.new(SEED)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      wanted = BitArray.new(width)
      index = random.rand(width)
      wanted[index] = true
      wanted_b, wanted_c = compute(scheme, random, width_log2, wanted)
      wanted_b.should eq(wanted_c)
    end
  end
end
