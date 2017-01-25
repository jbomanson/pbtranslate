require "../sorting_network_helper"

include PBTranslator

class HardCodedSortScheme
  def network(width : Width)
    Network::HardCodedSort.network(width)
  end
end

class WidthRange(R)
  def initialize(@value_range : R)
  end

  def each
    @value_range.each do |value|
      yield Width.from_value(value)
    end
  end
end

range = WidthRange.new(Network::HardCodedSort.width_value_range)

rounds = 400

seed = SEED ^ __FILE__.hash

scheme = HardCodedSortScheme.new

describe Scheme::MergeSort do
  it_passes_as_a_sorting_network(scheme, seed, range, rounds)
end
