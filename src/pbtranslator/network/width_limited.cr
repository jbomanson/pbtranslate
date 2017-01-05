struct PBTranslator::Network::WidthLimited(N, I)

  delegate size, depth, to: @network

  def initialize(@network : N, @width : I)
  end

  def host(visitor, *args, **options) : Void
    @network.host(Guide.new(visitor, @width), *args, **options)
  end

  private struct Guide(V, I)
    include Gate::Restriction

    def initialize(@visitor : V, @width : I)
    end

    def visit_gate(g : Gate(Or, Input, _), *args, **options) : Void
      limited = typeof(g).new?(Wires.new(wires, &.<(@width)))
      return unless limited
      @visitor.visit_gate(limited, *args, **options)
    end

    macro define_visit_gate(please_yield)
      def visit_gate(g : Gate(_, Output, _) | Gate(_, InPlace, _) | Gate(And, _, _), **options) : Void
        return unless g.wires.all? &.<(@width)
        @visitor.visit_gate(g, **options) {{
          (please_yield ? "{ |v| yield Guide.new(v, @width) }" : "").id
        }}
      end
    end

    define_visit_gate false
    define_visit_gate true

    def visit_region(layer : OOPSublayer.class, **options) : Void
      @visitor.visit_region(layer, **options) { |v| yield Guide.new(v, @width) }
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
