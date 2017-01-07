require "bit_array"

require "../gate"

# A version of `WireWeighted` with weights on only a subset of layers.
class PBTranslator::Network::PartiallyWireWeighted(C, I)
  include Gate::Restriction

  delegate size, to: @cache

  # Enhances a _network_ with _weights_ propagated through its gates and placed
  # on the output wires of gates on layers _i_ for which `bit_array[i]` is true.
  def initialize(*, @network : C, @bit_array : BitArray, weights : Array(I))
    Util.restrict(network, LayerCache)
    d = network.depth
    b = bit_array.size
    unless d == b
      raise ArgumentError.new("Missmatch between depth = #{d} and bits #{b}")
    end
    @layered_weights = Propagator.propagate(network, bit_array, I.zero, weights).as(Util::SliceMatrix(I))
  end

  # Returns the depth of this network that is the depth of the wrapped network
  # plus one.
  def depth
    @cache.depth + 1
  end

  # Hosts a visitor through `Layer` regions containing `Gate`s each together with
  # a named argument *output_weights* that is a tuple of `I`.
  def host(visitor v, way y : Way, *args, **options) : Void
    PassingGuide.guide(@network, @layered_weights, @bit_array, *args, **options, visitor: v, way: y)
  end

  # A visitor that propagates weights through a network stores some of them.
  private class Propagator(I)
    def self.propagate(network n, bit_array b, zero : I, weights w) forall I
      s = Util::SliceMatrix(I).new(b.count(true) + 1, w.size) { zero }
      p = Propagator.new(layered_weights: s, bit_array: b, weights: w)
      n.host(p, FORWARD)
      p.flush_weights(b.size)
      s
    end

    protected def initialize(*, @layered_weights : Util::SliceMatrix(I), @bit_array : BitArray, weights w)
      @scratch = Array(I).new(w.size).concat(w).as(Array(I))
      @parents = Array(Int32).new(w.size, &.itself)
      @index = 0
    end

    def visit_region(layer : Layer) : Void
      yield self
      flush_weights(layer.depth)
    end

    def visit_gate(g, *args, **options) : Void
      wires = g.wires
      scratch = @scratch
      parents = @parents
      roots = wires.map { |i| root_of(i) }
      least_root = roots.min_by { |i| scratch[i] }
      (wires + roots).each { |i| parents[i] = least_root }
    end

    protected def flush_weights(output_depth d)
      return unless d == 0 || @bit_array[d - 1]
      sink, is_early = next_sink
      if is_early
        march_weights(sink)
      else
        sink.copy_from(@scratch.to_unsafe, @scratch.size)
      end
    end

    private def next_sink
      i = @index
      j = i + 1
      @index = j
      {@layered_weights[i], j < @layered_weights.size}
    end

    private def march_weights(sink)
      scratch = @scratch
      scratch.each_with_index do |weight, index|
        root = root_of(index)
        root_weight = scratch[root]
        scratch[index] = root_weight
        sink[index] = weight - root_weight
      end
    end

    # Follows parent links up until a root node is found.
    private def root_of(wire)
      parents = @parents
      i = ~wire
      j = wire
      until i == j
        i = j
        j = parents[j]
      end
      i
    end
  end

  # A visitor that guides another and provides it with weights for output wires.
  private abstract struct PassingGuide(V, I, L, B)
    include Gate::Restriction

    private struct LayerGuide(V, I, L, B) < PassingGuide(V, I, L, B)
      def visit_region(layer : Layer) : Void
        @current_weights = next_weights_or_nil
        @visitor.visit_region(Layer.new(layer.depth + 1)) do |v|
          yield GateGuide.new(v, @current_weights, @layer_iterator, @bit_iterator)
        end
      end

      protected def pass_sweep(way y)
        c = next_weights
        @visitor.visit_region(Layer.new(0_u32)) do |v|
          y.each_with_index_in(c) do |weight, index|
            v.visit_gate(Gate.passthrough_at(index), output_weights: {weight})
          end
        end
      end

      private def next_weights_or_nil
        if @bit_iterator.next
          next_weights
        end
      end

      private def next_weights : Slice(I)
        c = @layer_iterator.next
        if c.is_a? Iterator::Stop
          raise "Iterated too many layers of weights"
        end
        c
      end
    end

    private struct GateGuide(V, I, L, B) < PassingGuide(V, I, L, B)
      def visit_gate(g : Gate, **options) : Void
        e = g.wires
        c = @current_weights
        o = if c; c.values_at(*e) else e.map { I.zero } end
        @visitor.visit_gate(g, **options, output_weights: o)
        # DEBUG {
        if c; e.each { |i| c[i] = -7777 } end
        # }
      end
    end

    def self.guide(network, layered_weights s, bit_array b, visitor v, way y) : Void
      g = LayerGuide.new(v, s.first, y.each_in(s), y.each_in(b))
      if y.is_a? Forward
        g.pass_sweep(y)
      end
      network.host(g, y)
      if y.is_a? Backward
        g.pass_sweep(y)
      end
    end

    protected def initialize(@visitor : V, @current_weights : Slice(I) | Nil, @layer_iterator : L, @bit_iterator : B)
    end
  end
end
