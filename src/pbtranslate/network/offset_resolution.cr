require "../network"
require "../number_types"
require "../offset"
require "../visitor"

class PBTranslate::Network::OffsetResolution(N)
  include Network

  delegate network_depth, network_read_count, network_width, network_write_count, to: @network

  def initialize(@network : N)
  end

  def host_reduce(visitor, memo)
    Guide.guide(@network, visitor, memo)
  end

  private struct Guide(V)
    include Visitor

    def self.guide(network, visitor, memo)
      network.host_reduce(Guide.new(visitor), memo)
    end

    delegate way, to: @visitor

    protected def initialize(@visitor : V, @offset = Distance.new(0))
    end

    def visit_region(offset : Offset) : Nil
      yield Guide.new(@visitor, @offset + offset.value)
    end

    def visit_gate(gate, memo, **options)
      @visitor.visit_gate(gate.shifted_by(@offset), memo, **options)
    end

    def visit_region(region) : Nil
      shifted_region =
        if region.responds_to? :shifted_by
          region.shifted_by(@offset)
        else
          region
        end
      @visitor.visit_region(shifted_region) do |region_visitor|
        yield Guide.new(region_visitor, @offset)
      end
    end
  end
end
