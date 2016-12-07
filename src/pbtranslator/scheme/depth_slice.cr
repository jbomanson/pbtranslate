require "../../width"

class PBTranslator::Scheme::DepthSlice(S, I, W)
  def initialize(*, @scheme : S, @range_proc : W -> Range(I, I))
    check_scheme(scheme)
  end

  def network(width w : W)
    n = @scheme.network(w)
    r = @range_proc.call(w)
    Network::DepthSlice.new(network: n, width: w.value, range: r)
  end

  private def check_scheme(scheme : WithDepth::Scheme)
  end
end
