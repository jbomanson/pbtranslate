require "../network/random"
require "./of_any_width"
require "./parameterized_by_depth"
require "../scheme"

# A scheme of networks consiting of a configured number of layers with randomly
# constructed comparators.
#
# The generated networks are of linear size, so that for *n* inputs they have
# *O(n)* gates, when the configured depth is regarded as constant.
struct PBTranslate::Scheme::RandomFromDepth
  include Scheme
  include OfAnyWidthMarker
  include ParameterizedByDepth

  declare_gate_options depth

  # Creates a scheme that generates networks with *depth* layers of gates
  # chosen randomly using the generator *random*.
  def initialize(*, @random : ::Random, @depth : Distance)
  end

  # Generates a network of the given *width*.
  def network(width w : Width)
    Network::Random.new(random: @random, depth: @depth, width: w)
  end
end
