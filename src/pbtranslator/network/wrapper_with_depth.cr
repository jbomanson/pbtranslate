struct PBTranslator::Network::WrapperWithDepth(N)
  getter network_depth : Distance

  def self.new(network n, *, width w : Width, way y : Way = FORWARD)
    self.new(n, network_depth: Network.compute_depth(n, y))
  end

  def initialize(@network : N, *, @network_depth : Distance)
  end

  forward_missing_to @network
end
