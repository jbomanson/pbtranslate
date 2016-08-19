require "spec"
require "../src/pbtranslator"

WIDTH_LOG2_MAX = 10
SEED = 482382392

# An object that counts the number of times any of its methods is called.
class MethodCallCounter
  delegate "[]", to: @h
  def initialize()
    @h = Hash(Symbol, UInt32).new(0_u32)
  end
  macro method_missing(call)
    @h[:{{call.name.id.stringify}}] += 1
  end
end

struct DepthCounter
  def initialize(size : Int)
    @array = Array(UInt32).new(size, 0_u32)
  end

  def visit(gate) : Void
    depth = @array.values_at(*gate.input_wires).max + 1
    gate.output_wires.each do |index|
      @array[index] = depth
    end
  end

  def depth
    @array.max
  end
end
