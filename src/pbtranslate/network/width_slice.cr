require "../gate"
require "../visitor"

struct PBTranslate::Network::WidthSlice(N)
  delegate network_depth, network_read_count, to: @network

  def self.new(network, count)
    new(network, begin: Distance.new(0), end: count)
  end

  def initialize(@network : N, *, @begin : Distance, @end : Distance)
  end

  def network_width : Distance
    @end - @begin
  end

  # Returns an upper bound on the number of writes done by this network.
  def network_write_count : Area
    {@network.network_write_count, Area.new(network_depth) * network_width}.min
  end

  def host(visitor v) : Nil
    vv = Guide.new(v, @begin, @end)
    @network.host(vv)
  end

  private struct Guide(V)
    include Visitor
    include Gate::Restriction

    delegate way, to: @visitor

    def initialize(@visitor : V, @begin : Distance, @end : Distance)
    end

    macro define_visit_gate(please_yield)
      def visit_gate(g : Gate(_, Output, _) | Gate(_, InPlace, _) | Gate(And, _, _), **options) : Nil
        b, e = @begin, @end
        return unless w = pick_wires(g, b, e, **options)
        h = g.class.new(w.map &.- b)
        @visitor.visit_gate(h, **options) {{
                                            (please_yield ? "{ |v| yield Guide.new(v, @begin, @end) }" : "").id
                                          }}
      end
    end

    define_visit_gate false
    define_visit_gate true

    private def pick_wires(g : Gate(_, Output, _) | Gate(_, InPlace, _), b, e, **options)
      s = g.wires
      all_potentially_anything?(s, b, e) ? s : nil
    end

    private def pick_wires(g : Gate(And, Input, _), b, e, **options)
      s = g.wires
      return false_and(s, b, **options) unless all_potentially_true?(g, b, e)
      p = s.find { |w| b <= w && w < e }
      raise "Bug with simplification in WidthSlice" unless p
      s.map do |w|
        if b <= w && w < e
          p = w
        end
        p
      end
    end

    private def all_potentially_anything?(s, b, e)
      s.all? { |w| b <= w && w < e }
    end

    private def all_potentially_true?(s, b, e)
      s.all? { |w| w < e }
    end

    private def false_and(s, b, *empty_args, drop_true : Nil, **options) : Nil
      if s.none? { |w| b <= w }
        raise "Simplification of And gates to constant true is not supported"
      end
    end

    private def false_and(s, b, **options)
      raise "Simplification of And gates to constant false is not supported"
    end

    def visit_region(region) : Nil
      @visitor.visit_region(region) { |v| yield Guide.new(v, @begin, @end) }
    end
  end
end
