require "../../width"

class PBTranslator::Scheme::DepthSlice(S, I, W)
  def initialize(*, @scheme : S, @range_proc : W, I -> Range(I, I))
    check_scheme(scheme)
  end

  def network(width w : W)
    n = @scheme.network(w)
    d = n.depth
    r = @range_proc.call(w, d)
    Network::DepthSlice.new(network: n, width: w.value, range: r)
  end

  private def check_scheme(scheme : WithDepth::Scheme)
  end
end
