require "../network/depth_slice"
require "./parameterized_by_depth"
require "../scheme"
require "../../util/restrict"
require "../../width"

# :nodoc:
class PBTranslate::Scheme::DepthSlice(S)
  include Scheme
  include ParameterizedByDepth

  module ::PBTranslate::Scheme
    # Creates a scheme that generates networks representing depth wise slices of
    # networks of this scheme, where the slices of acceptable depths are
    # obtained by evaluating the given *range_proc* on the width and distance
    # of each network.
    def to_scheme_depth_slice(&range_proc : Width, Distance -> Range(Distance, Distance)) : Scheme
      DepthSlice.new(self, range_proc)
    end
  end

  delegate gate_options, to: @scheme

  def initialize(@scheme : S, @range_proc : Width, Distance -> Range(Distance, Distance))
    gate_options &.restrict(depth: true)
  end

  def network(width w : Width)
    n = @scheme.network(w)
    d = n.network_depth
    r = @range_proc.call(w, d)
    Network::DepthSlice.new(network: n, range: r)
  end
end
