require "../scheme"

module PBTranslate::Network
  # Creates a scheme that wraps this single network.
  # The scheme returns this network in response to any`network` call
  # with the correct width of the network as an argument.
  def network_to_partial_flexible_scheme : Scheme
    NetworkToScheme.new(self)
  end
end

private struct NetworkToScheme(N)
  include Scheme
  include Scheme::WithArguments(Width::Flexible)

  def initialize(@network : N)
    @width_value = @network.network_width.as(Distance)
  end

  def network?(width : Width)
    if width.value == @width_value
      @network
    end
  end
end
