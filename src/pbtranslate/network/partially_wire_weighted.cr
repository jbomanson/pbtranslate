require "bit_array"

require "../gate"
require "../network"
require "../object"

# A version of `WireWeighted` with weights on only a subset of layers.
class PBTranslate::Network::PartiallyWireWeighted(C, W)
  include Gate::Restriction
  include Network

  delegate size, to: @network
  delegate network_read_count, network_width, network_write_count, to: @network

  # Enhances a _network_ with _weights_ propagated through its gates and placed
  # on the output wires of gates on layers _i_ for which `bit_array[i]` is true.
  def initialize(*, @network : C, @bit_array : BitArray, weights : Array(W))
    Util.restrict(network, LayerCache)
    d = network.network_depth
    b = bit_array.size
    unless d == b
      raise ArgumentError.new("Missmatch between depth = #{d} and bits #{b}")
    end
    @layered_weights = Propagator.propagate(network, bit_array, W.zero, weights).as(Util::SliceMatrix(W))
  end

  # Returns the depth of this network that is the depth of the wrapped network
  # plus one.
  def network_depth
    @network.network_depth + 1
  end

  # Hosts a visitor through `Layer` regions containing `Gate`s each together with
  # a named argument *output_weights* that is a tuple of `W`.
  def host_reduce(visitor, memo)
    PassingGuide.guide(@network, @layered_weights, @bit_array, visitor, memo)
  end

  # A visitor that propagates weights through a network and stores some of them.
  private class Propagator(W)
    include Visitor

    def self.propagate(network n, bit_array b, zero : W, weights w) forall W
      s = Util::SliceMatrix(W).new(b.count(true) + 1, w.size) { zero }
      p = new(layered_weights: s, bit_array: b, weights: w)
      n.host(p)
      p.flush_weights_last
      s
    end

    protected def initialize(*, @layered_weights : Util::SliceMatrix(W), @bit_array : BitArray, weights w)
      @scratch = Array(W).new(w.size).concat(w).as(Array(W))
      @parents = Array(Int32).new(w.size, &.itself)
      @index = 0
    end

    def visit_region(layer : Layer) : Nil
      yield self
      march_weights(next_sink) if @bit_array[layer.level]
    end

    def visit_gate(gate, memo, **options)
      gate.pbtranslate_receive_call_from(self, memo, **options)
    end

    def call(gate, memo, **options)
      # Join the connected components of the wires of gate.
      wires = gate.wires
      scratch = @scratch
      parents = @parents
      roots = wires.map { |i| root_of(i) }
      least_root_index = roots.min_by { |i| scratch[i] }.to_i
      (wires + roots).each { |i| parents[i] = least_root_index }
      memo
    end

    protected def flush_weights_last
      @layered_weights.last.copy_from(@scratch.to_unsafe, @scratch.size)
    end

    private def next_sink
      i = @index
      @index = i + 1
      @layered_weights[i]
    end

    private def march_weights(sink) : Nil
      scratch = @scratch
      scratch.each_with_index do |weight, index|
        root = root_of(index)
        root_weight = scratch[root]
        scratch[index] = root_weight
        sink[index] = weight - root_weight
      end
      # Reset connected components to be singleton sets.
      @parents.map_with_index! { |parent, index| index }
    end

    # Follows parent links up until a root node is found.
    private def root_of(wire) : Distance
      parents = @parents
      i = ~wire
      j = wire
      until i == j
        i = j
        j = parents[j]
      end
      Distance.new(i)
    end
  end

  # A visitor that guides another and provides it with weights for output wires.
  private abstract struct PassingGuide(V, W, L, B)
    include Visitor
    include Gate::Restriction

    private struct LayerGuide(V, W, L, B) < PassingGuide(V, W, L, B)
      def visit_region(layer : Layer) : Nil
        @current_weights = next_weights_or_nil
        @visitor.visit_region(Layer.new(layer.level + 1)) do |v|
          yield GateGuide.new(v, @current_weights, @layer_iterator, @bit_iterator)
        end
      end

      protected def pass_sweep(way y, memo)
        c = next_weights
        @visitor.visit_region(Layer.new(0_u32)) do |v|
          y.each_with_index_in(c) do |weight, index|
            memo =
              v.visit_gate(
                Gate.passthrough_at(Distance.new(index)),
                memo,
                level: Distance.new(0),
                output_weights: {weight},
              )
          end
        end
        memo
      end

      private def next_weights_or_nil
        if @bit_iterator.next
          next_weights
        end
      end

      private def next_weights : Slice(W)
        c = @layer_iterator.next
        if c.is_a? Iterator::Stop
          raise "Iterated too many layers of weights"
        end
        c
      end
    end

    private struct GateGuide(V, W, L, B) < PassingGuide(V, W, L, B)
      def visit_gate(gate : Gate, memo, **options)
        gate.pbtranslate_receive_call_from(self, memo, **options)
      end

      def call(gate : Gate, memo, *empty_args, level, **options)
        e = gate.wires
        c = @current_weights
        o = if c
              c.values_at(*e)
            else
              e.map { W.zero }
            end
        @visitor.visit_gate(
          gate,
          memo,
          **options,
          level: level + 1,
          output_weights: o,
        )
      end
    end

    delegate way, to: @visitor

    def self.guide(network n, layered_weights s, bit_array b, visitor v, memo)
      y = v.way
      g = LayerGuide.new(v, s.first, y.each_in(s), y.each_in(b))
      if y.is_a? Forward
        memo = g.pass_sweep(y, memo)
      end
      memo = n.host_reduce(g, memo)
      if y.is_a? Backward
        memo = g.pass_sweep(y, memo)
      end
      memo
    end

    protected def initialize(@visitor : V, @current_weights : Slice(W) | Nil, @layer_iterator : L, @bit_iterator : B)
    end
  end
end
