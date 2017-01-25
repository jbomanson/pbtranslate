require "../../util/restrict"
require "../../width"

class PBTranslator::Scheme::DepthSlice(S, W)
  def initialize(*, @scheme : S, @range_proc : W, Distance -> Range(Distance, Distance))
    Util.restrict(scheme, WithGateDepth::Scheme)
  end

  def network(width w : W)
    n = @scheme.network(w)
    d = n.network_depth
    r = @range_proc.call(w, d)
    Network::DepthSlice.new(network: n, width: w.value, range: r)
  end
end
