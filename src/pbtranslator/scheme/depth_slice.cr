require "../../width"

class PBTranslator::Scheme::DepthSlice(S, I, W)
    def initialize(@scheme : S, @range_block : W -> Range(I, I))
  end

  def network(width : W)
    network = @scheme.network(width)
    range = @range_block.call(width)
    Network::DepthSlice.new(network: network, width: width.value, range: range)
  end
end
