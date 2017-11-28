require "spec"
require "../src/pbtranslate"

include PBTranslate

WIDTH_LOG2_MAX = Distance.new(10)
SEED           = 482382392

# An object that counts the number of times its visit forward and backward.
class VisitCallCounter
  include Visitor

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

# A visitor that checks that all wire indices are nonnegative and not larger
# than a given threshold.
record WidthCheckingVisitor, width : Distance do
  include Visitor
  include Gate::Restriction

  def visit_gate(g : Gate, *args, **options) : Nil
    wires = g.wires
    unless wires.all? &.>=(0)
      raise "Expected nonnegative wires, got #{wires}"
    end
    unless wires.all? &.<(width)
      raise "Expected wires less than #{width}, got #{wires}"
    end
  end

  def visit_gate(g : Gate, *args, **options) : Nil
    visit_gate(g, *args, **options)
    yield self
  end

  def visit_region(layer : OOPSublayer.class) : Nil
    yield self
  end
end

class WidthPw2Range
  include Enumerable(Width::Pw2)

  def initialize(@log2_range : Range(Distance, Distance))
  end

  def each
    @log2_range.each do |log2|
      yield Width.from_log2(log2)
    end
  end
end

class WidthRange
  include Enumerable(Width::Flexible)

  def initialize(@value_range : Range(Distance, Distance))
  end

  def each
    @value_range.each do |value|
      yield Width.from_value(value)
    end
  end
end

module SpecHelper
  include PBTranslate

  def sort(a : Array(Bool))
    a.sort_by { |w| w ? 0 : 1 }
  end

  def sort(a)
    a.sort
  end

  def random_width_array(n, random, log_max = WIDTH_LOG2_MAX)
    a =
      Array.new(n) do
        Distance.new(2 ** (random.next_float * log_max))
      end
    a.sort
  end
end
