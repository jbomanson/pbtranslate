require "../sorting_network_helper"

include PBTranslator

class WidthPw2Range(R)
  def initialize(@log2_range : R)
  end

  def each
    @log2_range.each do |log2|
      yield Width.from_log2(log2)
    end
  end
end

range = WidthPw2Range.new(Distance.new(0)..WIDTH_LOG2_MAX)

rounds = 5

seed = SEED ^ __FILE__.hash

scheme_a = Network::HardCodedSort

scheme_b =
  Scheme::MergeSort::Recursive.new(
    Scheme::OEMerge::INSTANCE
  )

scheme = Scheme::WithFallback.new(scheme_a, scheme_b)

describe Scheme::WithFallback do
  it_passes_as_a_sorting_network(scheme, seed, range, rounds)
end