require "../network/depth_slice"
require "./parameterized_by_depth"
require "../scheme"
require "../../util/restrict"
require "../../width"

# A scheme of networks that select gates of other networks by keeping those with
# depths in a configured range of depths.
class PBTranslate::Scheme::DepthSlice(S)
  include Scheme
  include ParameterizedByDepth

  delegate gate_options, to: @scheme

  # Creates a scheme that generates networks representing depth wise slices of
  # networks of the given *scheme*, where the slices of acceptable depths are
  # obtained by evaluating the given *range_proc* on the width and distance of
  # each network.
  def initialize(*, @scheme : S, @range_proc : Width, Distance -> Range(Distance, Distance))
    gate_options &.restrict(depth: true)
  end

  # Generates a network of the given *width*.
  def network(width w : Width)
    n = @scheme.network(w)
    d = n.network_depth
    r = @range_proc.call(w, d)
    Network::DepthSlice.new(network: n, range: r)
  end
end
