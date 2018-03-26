require "digest"
require "spec"
require "../src/pbtranslate"

include PBTranslate

WIDTH_LOG2_MAX = Distance.new(10)
private WIDTH_MAX      = Distance.new(1) << WIDTH_LOG2_MAX
private SEED           = 482382392

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

  def visit_gate(gate : Gate(A, B, _), memo, **options) forall A, B
    @h[{A, B}] += Pair.new(1_u64, gate.wires.size.to_u64)
    memo
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

  def visit_gate(gate : Gate, memo, **options)
    wires = gate.wires
    unless wires.all? &.>=(0)
      raise "Expected nonnegative wires, got #{wires}"
    end
    unless wires.all? &.<(width)
      raise "Expected wires less than #{width}, got #{wires}"
    end
    memo
  end

  def visit_region(gate : Gate) : Nil
    visit_gate(gate, nil)
    yield self
  end

  def visit_region(layer : OOPSublayer.class)
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

struct VarietyExampleNetwork
  include Network

  def host_reduce(visitor, memo)
    wire_0 = Distance.new(0)
    wire_1 = Distance.new(1)
    wire_2 = Distance.new(2)
    memo = visitor.visit_gate(Gate.passthrough_at(wire_0), memo)
    memo = visitor.visit_gate(Gate.passthrough_at(wire_1), memo)
    memo = visitor.visit_gate(Gate.passthrough_at(wire_2), memo)
    memo = visitor.visit_gate(Gate.comparator_between(wire_0, wire_1), memo)
    memo = visitor.visit_gate(Gate.comparator_between(wire_1, wire_2), memo)
    memo = visitor.visit_gate(Gate.and_of(wire_1, wire_2), memo)
  end
end

module SpecHelper
  include PBTranslate
  extend self

  def file_specific_seed(file = __FILE__)
    SEED ^ Digest::MD5.hexdigest(file)[0...16].to_u64(base: 16)
  end

  def sort(a : Array(Bool))
    a.sort_by { |w| w ? 0 : 1 }
  end

  def sort(a)
    a.sort
  end

  # Returns an array of up to *size* distinct `Distance` values that starts with
  # `min + 0`, `min + 1`, `min + 2` and then continues with random values from
  # *min* to to *max* whose logarithms are uniformly distributed.
  def array_of_random_width(size, random, *, min = 0, max = WIDTH_MAX)
    unless min < max
      raise ArgumentError.new("Expected min < max, got #{min}, #{max}")
    end
    span_log = Math.log2(max - min + 1)
    Array
      .new(size) { |i| i < 3 ? i : 2.0 ** (random.next_float * span_log) }
      .uniq!
      .sort!
      .map { |value| Distance.new(min + value) }
  end

  def pw2_sort_odd_even(*args)
    Scheme
      .pw2_merge_odd_even
      .to_scheme_pw2_divide_and_conquer(*args)
      .to_scheme_with_offset_resolution
  end
end
