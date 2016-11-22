class PBTranslator::Scheme::DepthSlice(S, I)
  def initialize(@scheme : S, @range : Range(I, I))
  end

  def network(*args, width)
    network = @scheme.network(*args)
    Network::DepthSlice.new(network: network, width: width, range: @range)
  end
end
