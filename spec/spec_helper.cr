require "spec"
require "../src/pbtranslator"

include PBTranslator

WIDTH_LOG2_MAX =        10
SEED           = 482382392

# An object that counts the number of times its visit forward and backward.
class VisitCallCounter
  def initialize
    @h = Hash(String, UInt32).new(0_u32)
  end

  def visit(location, way : Way) : Void #, *args, **options) : Void
    @h[way.to_s] += 1
  end

  def count(way : Way)
    @h[way.to_s]
  end
end

struct DepthCounter
  include Gate::Restriction

  def initialize(size : Int)
    @array = Array(UInt32).new(size, 0_u32)
  end

  def visit(gate : Gate(_, InPlace, _), *args, **options) : Void
    input_wires = gate.wires
    depth = @array.values_at(*input_wires).max + 1
    output_wires = gate.wires
    output_wires.each do |index|
      @array[index] = depth
    end
  end

  def depth
    @array.max
  end
end
