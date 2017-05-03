require "../offset"

class PBTranslate::Network::OffsetResolution(N)
  delegate network_depth, network_read_count, network_width, network_write_count, to: @network

  def initialize(@network : N)
  end

  def host(visitor) : Nil
    Guide.guide(@network, visitor)
  end

  private struct Guide(V)
    include Visitor

    def self.guide(network, visitor)
      network.host(Guide.new(visitor))
    end

    delegate way, to: @visitor

    protected def initialize(@visitor : V, @offset = Distance.new(0))
    end

    def visit_region(offset : Offset) : Nil
      yield Guide.new(@visitor, @offset + offset.value)
    end

    def visit_region(region) : Nil
      @visitor.visit_region(region) do |region_visitor|
        yield Guide.new(region_visitor, @offset)
      end
    end

    def visit_gate(g, **options) : Nil
      @visitor.visit_gate(g.shifted_by(@offset), **options)
    end

    def visit_gate(g, **options) : Nil
      @visitor.visit_gate(g.shifted_by @offset, **options) do |gate_visitor|
        yield Guide.new(gate_visitor, @offset)
      end
    end
  end
end
