require "../network/level_slice"
require "./parameterized_by_depth"
require "../scheme"
require "../../util/restrict"
require "../../width"

# :nodoc:
class PBTranslate::Scheme::LevelSlice(S)
  include Scheme
  include ParameterizedByDepth

  module ::PBTranslate::Scheme
    # Creates a scheme that generates networks representing level wise slices of
    # networks of this scheme, where the slices of acceptable levels are
    # obtained by evaluating the given *range_proc* on the width and depth of
    # each network.
    def to_scheme_level_slice(&range_proc : Width, Distance -> Range(Distance, Distance)) : Scheme
      LevelSlice.new(self, range_proc)
    end
  end

  delegate_scheme_details_to @scheme
  delegate gate_options, to: @scheme

  def initialize(@scheme : S, @range_proc : Width, Distance -> Range(Distance, Distance))
    gate_options &.restrict(level: true)
  end

  def network(width w : Width)
    n = @scheme.network(w)
    d = n.network_depth
    r = @range_proc.call(w, d)
    Network::LevelSlice.new(network: n, range: r)
  end
end
