struct PBTranslator::Scheme::WidthLimited(S)
  def initialize(@scheme : S)
  end

  def network(width)
    pw2width = Math.pw2ceil(width)
    width_log2 = (pw2width - 1).popcount
    Network::WidthLimited.new(@scheme.network(width_log2), width)
  end
end
