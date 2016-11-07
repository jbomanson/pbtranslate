struct PBTranslator::Network::WidthLimited(N, I)

  delegate size, depth, to: @network

  def initialize(@network : N, @width : I)
  end

  macro define_visit(prefix)
    def {{prefix.id}}visit(visitor, offset = I.new(0))
      @network.{{prefix.id}}visit(Visitor.new(visitor, @width), offset)
    end
  end

  define_visit ""
  define_visit reverse_

  private struct Visitor(V, I)
    include Gate::Restriction

    def initialize(@visitor : V, @width : I)
    end

    macro define_visit_easy(prefix, please_yield)
      def {{prefix.id}}visit(gate : Gate(_, Output, _) | Gate(_, InPlace, _) | Gate(And, _, _)) : Void
        return unless gate.wires.all? &.<(@width)
        @visitor.{{prefix.id}}visit(gate) {{
          (please_yield ? "{ |v| yield Visitor.new(v, @width) }" : "").id
        }}
      end

      def {{prefix.id}}visit(gate : Gate(Or, Input, _)) : Void
        limited_gate = typeof(gate).new?(Wires.new(wires, &.<(@width)))
        return unless limited_gate
        @visitor.{{prefix.id}}visit(limited_gate) {{
          (please_yield ? "{ |v| yield Visitor.new(v, @width) }" : "").id
        }}
      end
    end

    define_visit_easy "", false
    define_visit_easy "", true
    define_visit_easy reverse_, false
    define_visit_easy reverse_, true

    def visit(layer : OOPLayer.class)
      @visitor.visit(layer) { |v| yield Visitor.new(v, @width) }
    end

    private struct Wires(T, P)
      def self.new?(wires)
        picks = wires.map { |w| yield(w) }
        picks.any? ? new(wires, picks) : nil
      end

      def initialize(@wires : T, @picks : P)
      end

      macro define_each(prefix)
        def {{prefix.id}}each
          @wires.{{prefix.id}}each_with_index do |w, i|
            @picks[i] && (yield w)
          end
        end
      end

      define_each ""
      define_each _reverse
    end
  end
end
