require "../network/random"
require "./of_any_width"
require "./parameterized_by_depth"
require "../scheme"

class PBTranslate::Scheme::RandomFromDepth
  include Scheme
  include OfAnyWidthMarker
  include ParameterizedByDepth

  declare_gate_options depth

  def initialize(*, @random : ::Random, @depth : Distance)
  end

  def network(width w : Width)
    Network::Random.new(random: @random, depth: @depth, width: w)
  end
end
