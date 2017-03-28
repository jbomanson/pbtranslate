require "../gate_options"
require "../network/offset_resolution"

class PBTranslator::Scheme::OffsetResolution(S)
  include GateOptions::Module

  delegate gate_options, to: @scheme

  def initialize(@scheme : S)
  end

  def network(width : Width)
    Network::OffsetResolution.new(@scheme.network(width))
  end

  def with_depth
    @scheme.with_depth do |without|
      OffsetResolution.new(without).with_depth_added
    end
  end
end
