require "../offset"

class PBTranslator::Network::OffsetResolution(N)
  delegate network_depth, network_read_count, network_width, network_write_count, to: @network

  def initialize(@network : N)
  end

  def host(visitor, way : Way) : Nil
    Guide.guide(@network, visitor, way)
  end

  private struct Guide(V)
    def self.guide(network, visitor, way)
      network.host(Guide.new(visitor), way)
    end

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
