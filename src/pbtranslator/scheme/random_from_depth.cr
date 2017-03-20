require "../gate_options"

class PBTranslator::Scheme::RandomFromDepth
  include GateOptions::Module
  include OfAnyWidthMarker
  include ParameterizedByDepth

  declare_gate_options depth

  def initialize(*, @random : ::Random, @depth : Distance)
  end

  def network(width w : Width)
    Network::Random.new(random: @random, depth: @depth, width: w)
  end
end
