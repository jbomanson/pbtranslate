struct PBTranslate::Network::WrapperWithDepth(N)
  getter network_depth : Distance

  def self.new(network n)
    new(n, network_depth: Network.compute_depth(n))
  end

  def initialize(@network : N, *, @network_depth : Distance)
  end

  forward_missing_to @network
end
