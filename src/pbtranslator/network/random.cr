# A comparator network of layers with maximal size and randomly connected wires.
class PBTranslator::Network::Random(C)
  include WithDepth::Network

  delegate depth, size, host, to: @cache

  private def self.layer_cache_class_for(w : Width(I)) forall I
    LayerCache.class_for(Gate.comparator_between(I.zero, I.zero), depth: 0_u32)
  end

  def self.new(*, random r : ::Random, width w : Width(I), depth d : UInt32)
    n = Generator.new(random: r, width: w, depth: d)
    new(layer_cache_class_for(w).new(network: n, width: w))
  end

  protected def initialize(@cache : C)
  end

  private struct Generator(I)
    include WithDepth::Network

    getter depth

    def initialize(*, @random : ::Random, width w : Width(I), @depth : UInt32)
      @width = w.value.as(I)
      @called = false
    end

    def size
      (@width / 2) * @depth
    end

    def host(visitor, way : Way) : Void
      if @called
        raise "This Generator has already hosted"
      end
      @called = true
      a = Array.new(@width) { |i| I.new(i) }
      r = @random
      way.each_in(typeof(@depth).zero...@depth) do |d|
        a.shuffle! random: r
        each_pair(a) do |i, j|
          x, y = i < j ? {i, j} : {j, i}
          g = Gate.comparator_between(x, y)
          visitor.visit(g, way, depth: d)
        end
      end
    end

    private def each_pair(a)
      0.upto(a.size / 2 - 1) do |i|
        j = 2 * i
        yield a[j], a[j + 1]
      end
    end
  end
end
