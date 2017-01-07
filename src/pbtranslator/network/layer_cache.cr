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
        way.each_with_index_in(layer) do |element, index|
          element_host(layer_visitor, element, index)
        end
      end
    end
  end

  private def element_host(layer_visitor, element, index)
    case element
    when Tuple
      gate, options = element
      layer_visitor.visit_gate(gate, **options)
    when Unused
      layer_visitor.visit_gate(Gate.passthrough_at(index))
    end
  end

  private struct Used
  end

  private struct Unused
  end

  private struct Collector(G, O)
    def self.collect(*, network n, width w) : Util::SliceMatrix(Used | Unused | {G, O})
      s = Util::SliceMatrix(Used | Unused | {G, O}).new(n.depth, w.value) { Unused.new }
      n.host(self.new(s), FORWARD)
      s
    end

    protected def initialize(@layers : Util::SliceMatrix(Used | Unused | {G, O}))
    end

    def visit_gate(g : G, **options : **O) : Void
      f, t = first_and_rest(*g.wires)
      d = options[:depth]
      r = @layers[d]
      unless r[f].is_a? Unused
        raise "Internal error: two gates for wire #{f} at depth #{d}"
      end
      r[f] = {g, options}
      t.each { |i| r[i] = Used.new }
    end

    def visit_gate(*args, **options) : Void
    end

    private def first_and_rest(f, *t)
      {f, t}
    end
  end
end
