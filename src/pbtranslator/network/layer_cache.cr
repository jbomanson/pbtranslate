require "../gate"
require "../gate_options"
require "../named_tuple"

# A network of gates stored explicitly for enumeration layer by layer.
class PBTranslator::Network::LayerCache(G, O)
  include Gate::Restriction

  # Returns the appropriate LayerCache class for storing visit calls with
  # arguments of the types used here.
  def self.class_for(gate : G, **options : **O) forall G, O
    LayerCache(G, O)
  end

  # Delegated to the original network.
  getter network_write_count : Area

  # Caches gates of _network_ and returns a network for enumerating them layer
  # by layer.
  def initialize(*, network n, width w : Width)
    @network_write_count = n.network_write_count.as(Area)
    @layers = Collector(G, O).collect(network: n, width: w)
  end

  # Returns the computed depth of the network of stored gates.
  def network_depth : Distance
    Distance.new(@layers.size)
  end

  # Returns the given width of the network.
  def network_width : Distance
    Distance.new(@layers.columns)
  end

  # Hosts a visitor layer by layer through stored gates and generated
  # `Passthrough` gates.
  def host(visitor) : Nil
    visitor.way.each_with_index_in(@layers) do |layer, depth_i|
      depth = Distance.new(depth_i)
      visitor.visit_region(Layer.new(depth)) do |layer_visitor|
        visitor.way.each_with_index_in(layer) do |element, index|
          element_host(depth, layer_visitor, element, index)
        end
      end
    end
  end

  private def element_host(depth, layer_visitor, element, index)
    case element
    when Tuple
      gate, options = element
      layer_visitor.visit_gate(gate, **options)
    when Unused
      gate = Gate.passthrough_at(Distance.new(index))
      options = {depth: depth}
      layer_visitor.visit_gate(gate, **options)
    end
  end

  private struct Used
  end

  private struct Unused
  end

  private struct Collector(G, O)
    include Visitor
    include Visitor::DefaultMethods

    def self.collect(*, network n, width w) : Util::SliceMatrix(Used | Unused | {G, O})
      s = Util::SliceMatrix(Used | Unused | {G, O}).new(n.network_depth, w.value) { Unused.new }
      n.host(self.new(s))
      s
    end

    protected def initialize(@layers : Util::SliceMatrix(Used | Unused | {G, O}))
    end

    def visit_gate(g : G, **options : **O) : Nil
      f, t = first_and_rest(*g.wires)
      d = options[:depth]
      r = @layers[d]
      unless r[f].is_a? Unused
        raise "Internal error: two gates for wire #{f} at depth #{d}"
      end
      r[f] = {g, options}
      t.each { |i| r[i] = Used.new }
    end

    def visit_gate(*args, **options) : Nil
    end

    private def first_and_rest(f, *t)
      {f, t}
    end
  end
end
