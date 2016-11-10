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
