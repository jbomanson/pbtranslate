require "../gate_options"
require "./parameterized_by_depth"
require "../../util/restrict"
require "../../width"

class PBTranslator::Scheme::DepthSlice(S, W)
  include GateOptions::Module
  include ParameterizedByDepth

  delegate gate_options, to: @scheme

  def initialize(*, @scheme : S, @range_proc : W, Distance -> Range(Distance, Distance))
    gate_options &.restrict(depth: true)
  end

  def network(width w : W)
    n = @scheme.network(w)
    d = n.network_depth
    r = @range_proc.call(w, d)
    Network::DepthSlice.new(network: n, width: w.value, range: r)
  end
end
