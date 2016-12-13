struct PBTranslator::Network::WidthLimited(N, I)

  delegate size, depth, to: @network

  def initialize(@network : N, @width : I)
  end

  def host(visitor, *args, **options) : Void
    @network.host(Visitor.new(visitor, @width), *args, **options)
  end

  private struct Visitor(V, I)
    include Gate::Restriction

    def initialize(@visitor : V, @width : I)
    end

    macro define_visit(please_yield)
      def visit(gate : Gate(_, Output, _) | Gate(_, InPlace, _) | Gate(And, _, _), *args, **options) : Void
        return unless gate.wires.all? &.<(@width)
        @visitor.visit(gate, *args, **options) {{
          (please_yield ? "{ |v| yield Visitor.new(v, @width) }" : "").id
        }}
      end

      # TODO: Move this outside of the macro and remove the yield.
      def visit(gate : Gate(Or, Input, _), *args, **options) : Void
        limited_gate = typeof(gate).new?(Wires.new(wires, &.<(@width)))
        return unless limited_gate
        @visitor.visit(limited_gate, *args, **options) {{
          (please_yield ? "{ |v| yield Visitor.new(v, @width) }" : "").id
        }}
      end
    end

    define_visit false
    define_visit true

    def visit(layer : OOPLayer.class, *args, **options) : Void
      @visitor.visit(layer, *args, **options) { |v| yield Visitor.new(v, @width) }
    end

    private struct Wires(T, P)
      def self.new?(wires)
        picks = wires.map { |w| yield(w) }
        picks.any? ? new(wires, picks) : nil
      end

      def initialize(@wires : T, @picks : P)
      end

      Way.define_each

      private def each_in(way)
        way.each_index_to(@wires) do |i|
          @picks[i] && (yield @wires[i])
        end
      end
    end
  end
end
