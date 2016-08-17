require "spec"
require "../src/pbtranslator"

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
  
  def visit_comparator(i, j) : Void
    depth = @array.values_at(i, j).max + 1
    {i, j}.each do |index|
      @array[index] = depth
    end
  end

  def depth
    @array.max
  end
end
