struct PBTranslator::Network::WrapperWithDepth(N)
  getter depth : Distance

  def self.new(network n, *, width w : Width, way y : Way = FORWARD)
    self.new(n, depth: Network.compute_depth(n, width: w, way: y))
  end

  def initialize(@network : N, *, @depth : Distance)
  end

  forward_missing_to @network
end
