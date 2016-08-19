require "bit_array"

require "../spec_helper"

record ArrayConeSwap(T), array : Array(T) do
  def visit(comparator) : Void
    i, j = comparator.wires
    x, y = comparator.output_cone
    a = @array[i]
    b = @array[j]
    c = a < b
    @array[i] = c ? a : b if x
    @array[j] = c ? b : a if y
  end
end

record ArrayConeNot do
  def visit(comparator) : Void
    x, y = comparator.output_cone
    if x || y
      raise "Expected two false booleans, got #{{x, y}}"
    end
  end
end

scheme = PBTranslator::Scheme::MergeSort::DEFAULT_INSTANCE

# Returns a tuple of computed and a tuple of correct wanted outputs.
private def compute(scheme, random, width_log2, wanted)
  width = 1 << width_log2
  a = Array.new(width) { random.rand }
  b = a.clone
  c = a.sort
  PBTranslator::Cone.visit(
    network: scheme.network(width_log2),
    visitor: ArrayConeSwap.new(b),
    wanted:  wanted,
  )
  {b, c}.map do |array|
    index = 0
    array.select do
      wanted[index].tap do
        index += 1
      end
    end
  end
end

describe PBTranslator::Cone do
  it "works with universally unwanted outputs and merge sorting networks" do
    random = Random.new(SEED)
    (0..WIDTH_LOG2_MAX).each do |width_log2|
      width = 1 << width_log2
      wanted = BitArray.new(width, false)
      PBTranslator::Cone.visit(
        network: scheme.network(width_log2),
        visitor: ArrayConeNot.new,
        wanted:  wanted,
      )
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
