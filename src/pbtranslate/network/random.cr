# A comparator network of layers with maximal size and randomly connected wires.
struct PBTranslate::Network::Random(C)
  delegate network_depth, network_read_count, network_width, network_write_count, host, to: @cache

  private def self.layer_cache_class_for(w : Width)
    LayerCache.class_for(Gate.comparator_between(Distance.zero, Distance.zero), level: Distance.zero)
  end

  def self.new(*, random r : ::Random, width w : Width, depth d : Distance)
    n = Generator.new(random: r, width: w, depth: d)
    new(layer_cache_class_for(w).new(network: n, width: w))
  end

  protected def initialize(@cache : C)
  end

  private struct Generator
    getter network_depth : Distance
    getter network_width : Distance

    def initialize(*, @random : ::Random, width w : Width, depth @network_depth : Distance)
      @network_width = w.value.as(Distance)
      @called = false
    end

    def network_read_count : Area
      Area.new(@network_width / 2) * @network_depth * 2
    end

    def network_write_count : Area
      network_read_count
    end

    def host(visitor) : Nil
      if @called
        raise "This Generator has already hosted"
      end
      @called = true
      a = Array.new(@network_width) { |i| Distance.new(i) }
      r = @random
      visitor.way.each_in(typeof(@network_depth).zero...@network_depth) do |d|
        a.shuffle! random: r
        each_pair(a) do |i, j|
          x, y = i < j ? {i, j} : {j, i}
          g = Gate.comparator_between(x, y)
          visitor.visit_gate(g, level: d)
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
