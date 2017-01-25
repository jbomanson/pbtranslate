struct PBTranslator::Network::WidthLimited(N)

  delegate network_depth, network_read_count, to: @network

  def initialize(@network : N, @width : Distance)
  end

  def network_width : Distance
    @width
  end

  # Returns an upper bound on the number of writes done by this network.
  def network_write_count : Area
    {@network.network_write_count, Area.new(network_depth) * network_width}.min
  end

  def host(visitor v, way y : Way) : Nil
    vv = Guide.new(v, @width)
    @network.host(vv, y)
  end

  private struct Guide(V)
    include Gate::Restriction

    def initialize(@visitor : V, @width : Distance)
    end

    def visit_gate(g : Gate(Or, Input, _), *args, **options) : Nil
      limited = typeof(g).new?(Wires.new(wires, &.<(@width)))
      return unless limited
      @visitor.visit_gate(limited, *args, **options)
    end

    macro define_visit_gate(please_yield)
      def visit_gate(g : Gate(_, Output, _) | Gate(_, InPlace, _) | Gate(And, _, _), **options) : Nil
        return unless g.wires.all? &.<(@width)
        @visitor.visit_gate(g, **options) {{
          (please_yield ? "{ |v| yield Guide.new(v, @width) }" : "").id
        }}
      end
    end

    define_visit_gate false
    define_visit_gate true

    def visit_region(region) : Nil
      @visitor.visit_region(region) { |v| yield Guide.new(v, @width) }
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
