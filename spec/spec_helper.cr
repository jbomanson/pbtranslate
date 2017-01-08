require "spec"
require "../src/pbtranslator"

include PBTranslator

WIDTH_LOG2_MAX =        10
SEED           = 482382392

# An object that counts the number of times its visit forward and backward.
class VisitCallCounter
  def initialize
    @h = Hash({Gate::Function, Gate::Form}, UInt32).new(0_u32)
  end

  def visit_gate(g : Gate(A, B, _), **options) : Void forall A, B
    @h[{A, B}] += 1
  end

  def visit_region(region) : Void
    yield self
  end

  def count(a : Gate::Function, b : Gate::Form)
    @h[{a, b}]
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
        (2 ** (random.next_float * WIDTH_LOG2_MAX)).to_i
      end
    a.sort
  end
end
