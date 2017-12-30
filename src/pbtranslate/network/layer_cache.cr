require "../gate"
require "../network"
require "../util/slice_matrix"

# A network of gates stored explicitly for enumeration layer by layer.
class PBTranslate::Network::LayerCache(G)
  include Gate::Restriction
  include Network

  # Delegated to the original network.
  getter network_write_count : Area

  # Caches gates of _network_ and returns a network for enumerating them layer
  # by layer.
  def self.new(network : Network, width : Width)
    new(network, width, typeof(network.gate_with_options_for_typeof))
  end

  private def initialize(
    network : Network,
    width : Width,
    gate_with_options : G.class
  )
    @network_write_count = network.network_write_count.as(Area)
    @layers = Collector(G).collect(network: network, width: width)
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
  def host_reduce(visitor, memo)
    visitor.way.each_with_index_in(@layers) do |layer, level_i|
      level = Distance.new(level_i)
      visitor.visit_region(Layer.new(level)) do |layer_visitor|
        visitor.way.each_with_index_in(layer) do |element, index|
          memo = element_host_reduce(level, layer_visitor, element, index, memo)
        end
      end
    end
    memo
  end

  private def element_host_reduce(level, layer_visitor, element, index, memo)
    case element
    when Tuple
      gate, options = element
      layer_visitor.visit_gate(gate, memo, **options)
    when Unused
      gate = Gate.passthrough_at(Distance.new(index))
      options = {level: level}
      layer_visitor.visit_gate(gate, memo, **options)
    else
      memo
    end
  end

  private struct Used
  end

  private struct Unused
  end

  private struct Collector(G)
    include Visitor
    include Visitor::DefaultMethods

    def self.collect(*, network n, width w) : Util::SliceMatrix(Used | Unused | G)
      s = Util::SliceMatrix(Used | Unused | G).new(n.network_depth, w.value) { Unused.new }
      n.host(new(s))
      s
    end

    protected def initialize(@layers : Util::SliceMatrix(Used | Unused | G))
    end

    def visit_gate(gate, memo, **options)
      f, t = first_and_rest(*gate.wires)
      d = options[:level]
      r = @layers[d]
      unless r[f].is_a? Unused
        raise "Internal error: two gates for wire #{f} at level #{d}"
      end
      r[f] = {gate, options}
      t.each { |i| r[i] = Used.new }
      memo
    end

    private def first_and_rest(f, *t)
      {f, t}
    end
  end
end
