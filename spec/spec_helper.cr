require "spec"
require "../src/pbtranslator"

include PBTranslator

WIDTH_LOG2_MAX = Distance.new(10)
SEED           = 482382392

# An object that counts the number of times its visit forward and backward.
class VisitCallCounter
  record Pair, count : UInt64 = 0_u64, wire_count : UInt64 = 0_u64 do
    def +(other)
      Pair.new(count + other.count, wire_count + other.wire_count)
    end
  end

  def initialize
    @h = Hash({Gate::Function, Gate::Form}, Pair).new(Pair.new)
  end

  def visit_gate(g : Gate(A, B, _), **options) : Nil forall A, B
    @h[{A, B}] += Pair.new(1_u64, g.wires.size.to_u64)
  end

  def visit_region(region) : Nil
    yield self
  end

  def count(a : Gate::Function, b : Gate::Form)
    @h[{a, b}].count
  end

  def wire_count(a : Gate::Function, b : Gate::Form)
    @h[{a, b}].wire_count
  end
end

module SpecHelper
  include PBTranslator

  def sort(a : Array(Bool))
    a.sort_by { |w| w ? 0 : 1 }
  end

  def sort(a)
    a.sort
  end

  def random_width_array(n, random)
    a =
      Array.new(n) do
        Distance.new(2 ** (random.next_float * WIDTH_LOG2_MAX))
      end
    a.sort
  end
end
