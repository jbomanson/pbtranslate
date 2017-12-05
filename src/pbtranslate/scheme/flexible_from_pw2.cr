require "../scheme"

# A scheme of networks of arbitrary widths based on a scheme of type *S* that
# generates networks of widths that are powers of two.
#
# The arbitrary width networks are obtained by generating sufficiently large
# base networks and ignoring any excess wires at high positions.
# The depths of the resulting networks are generally the same as those of the
# base networks.
struct PBTranslate::Scheme::FlexibleFromPw2(S)
  include Scheme
  include FlexibleMarker

  delegate gate_options, to: @scheme

  # Creates a width limited scheme based on the given *scheme*.
  def initialize(@scheme : S)
  end

  # Generates a network of the given *width*.
  def network(width : Width)
    Network::WidthSlice.new(@scheme.network(width.to_pw2), width.value)
  end
end
