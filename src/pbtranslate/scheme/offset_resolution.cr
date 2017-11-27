require "../depth_tracking/scheme"
require "../network/offset_resolution"
require "../scheme"

# A scheme of networks obtained by resolving all `Offset` regions in the
# networks of a base scheme of type *S*.
#
# Networks of the base scheme may issue *#visit_region* calls with `Offset`
# arguments on visitors.
# Networks of this scheme will flatten any such regions and apply the received
# offsets to the gates within the regions.
# Consequently, a visitor of these networks does not need to implement
# *#visit_region* for `Offset` arguments.
class PBTranslate::Scheme::OffsetResolution(S)
  include Scheme

  delegate gate_options, to: @scheme

  # Creates a scheme that represents the given *scheme* with any `Offset`s
  # resolved away.
  def initialize(@scheme : S)
  end

  # Generates a network of the given *width*.
  def network(width : Width)
    Network::OffsetResolution.new(@scheme.network(width))
  end

  # See `Scheme#with_gate_depth`.
  def with_gate_depth
    @scheme.with_gate_depth do |without|
      OffsetResolution.new(without).with_gate_depth_added
    end
  end
end
