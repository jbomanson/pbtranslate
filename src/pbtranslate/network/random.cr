require "../network"

# A comparator network of layers with maximal size and randomly connected wires.
struct PBTranslate::Network::Random(C)
  include Network

  delegate network_depth, network_read_count, network_width, network_write_count, host_reduce, to: @cache

  def self.new(*, random r : ::Random, width w : Width, depth d : Distance)
    n = Generator.new(random: r, width: w, depth: d)
    new(LayerCache.new(n, w))
  end

  protected def initialize(@cache : C)
  end

  private struct Generator
    include Network

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

    def host_reduce(visitor, memo)
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
          gate = Gate.comparator_between(x, y)
          memo = visitor.visit_gate(gate, memo, level: d)
        end
      end
      memo
    end

    private def each_pair(a)
      0.upto(a.size / 2 - 1) do |i|
        j = 2 * i
        yield a[j], a[j + 1]
      end
    end
  end
end
