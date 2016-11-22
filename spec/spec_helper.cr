require "spec"
require "../src/pbtranslator"

include PBTranslator

WIDTH_LOG2_MAX =        10
SEED           = 482382392

# An object that counts the number of times its visit forward and backward.
class VisitCallCounter
  def initialize
    @h = Hash({Gate::Function, Gate::Form, String}, UInt32).new(0_u32)
  end

  def visit(gate : Gate(A, B, _), way : Way) : Void
    @h[{A, B, way.to_s}] += 1
  end

  def count(a : Gate::Function, b : Gate::Form, way : Way)
    @h[{a, b, way.to_s}]
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
