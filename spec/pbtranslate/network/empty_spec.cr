require "../sorting_network_helper"

include PBTranslate

private class EmptyScheme
  include Scheme
  include Scheme::WithArguments(Width::Flexible)

  def network(width : Width)
    unless width.value == 0
      raise "Unexpected nonzero width #{width}"
    end
    Network.empty
  end
end

range = WidthRange.new(Distance.new(0)..Distance.new(0))
rounds = 1
seed = SEED ^ __FILE__.hash
scheme = EmptyScheme.new.to_scheme_with_offset_resolution

describe "Network.empty" do
  it_hosts_like_a_sorting_network(scheme, seed, range, rounds)
end
