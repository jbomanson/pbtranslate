# A network of gates stored explicitly for enumeration layer by layer.
class PBTranslator::Network::LayerCache(G, O)
  include Gate::Restriction
  include WithDepth::Network

  # Returns the appropriate LayerCache class for storing visit calls with
  # arguments of the types used here.
  def self.class_for(gate : G, **options : **O) forall G, O
    LayerCache(G, O)
  end

  getter size

  # Caches gates of _network_ and returns a network for enumerating them layer
  # by layer.
  def initialize(*, network n : WithDepth::Network, width w : Width)
    @size = n.size.as(Int32)
    @layers = Collector(G, O).collect(network: n, width: w)
  end

  def depth
    @layers.size
  end

  def host(visitor, way : Way) : Void
    way.each_with_index_in(@layers) do |layer, index|
      visitor.visit_region(Layer.new(index.to_u32)) do |layer_visitor|
        way.each_in(layer) do |element|
          next unless element
          gate, options = element
          layer_visitor.visit_gate(gate, **options)
        end
      end
    end
  end

  private struct Collector(G, O)
    def self.collect(*, network n, width w) : Util::SliceMatrix(Nil | {G, O})
      s = Util::SliceMatrix(Nil | {G, O}).new(n.depth, w.value) { nil }
      n.host(self.new(s), FORWARD)
      s
    end

    protected def initialize(@layers : Util::SliceMatrix(Nil | {G, O}))
    end

    def visit_gate(g : G, **options : **O) : Void
      w = g.wires.first
      d = options[:depth]
      r = @layers[d]
      if r[w]
        raise "Internal error: two gates for wire #{w} at depth #{d}"
      end
      r[w] = {g, options}
    end

    def visit_gate(*args, **options) : Void
    end
  end
end
