struct PBTranslator::Network::WrapperWithDepth(N)
  getter depth : UInt32

  def self.new(network n, *, width w : Width, way y : Way = FORWARD)
    self.new(n, depth: Network.compute_depth(n, width: w, way: y))
  end

  def initialize(@network : N, *, @depth : UInt32)
  end

  forward_missing_to @network
end
