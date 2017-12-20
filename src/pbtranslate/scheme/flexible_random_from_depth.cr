require "../network/random"
require "./flexible"
require "./parameterized_by_depth"
require "../scheme"

# :nodoc:
struct PBTranslate::Scheme::FlexibleRandomFromDepth
  include Scheme
  include FlexibleMarker
  include ParameterizedByDepth

  module ::PBTranslate
    # Creates a scheme scheme of networks consiting of *depth* layers with
    # comparators constructed using the given *random* generator.
    #
    # The size of the generated networks is proprotional to both the given
    # *depth* and the width of the inputs.
    # That is, they have *O(d n)* gates where d is the depth and n the width.
    def Scheme.flexible_random_from_depth(*, random : ::Random, depth : Distance) : Scheme
      FlexibleRandomFromDepth.new(random, depth)
    end
  end

  def initialize(@random : ::Random, @depth : Distance)
  end

  def network(width w : Width)
    Network::Random.new(random: @random, depth: @depth, width: w)
  end
end
