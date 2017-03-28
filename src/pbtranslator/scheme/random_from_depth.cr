require "../scheme"

class PBTranslator::Scheme::RandomFromDepth
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
