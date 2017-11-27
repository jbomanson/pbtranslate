require "../sorting_network_helper"

include PBTranslate

class EmptyScheme
  include Scheme

  declare_gate_options

  def initialize
  end

  def network(width : Width)
    unless width.value == 0
      raise "Unexpected nonzero width #{width}"
    end
    Network::Empty::INSTANCE
  end
end

range = WidthRange.new(Distance.new(0)..Distance.new(0))
rounds = 1
seed = SEED ^ __FILE__.hash
scheme =
  Scheme::OffsetResolution.new(
    EmptyScheme.new
  )

describe Network::Empty do
  it_acts_like_a_sorting_network(scheme, seed, range, rounds)
end