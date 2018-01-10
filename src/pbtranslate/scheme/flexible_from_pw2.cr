require "../scheme"

# :nodoc:
struct PBTranslate::Scheme::FlexibleFromPw2(S)
  include Scheme
  include FlexibleMarker

  module ::PBTranslate::Scheme
    # Creates a version of this scheme that generates networks of any widths,
    # as opposed to only widths that are powers of two.
    #
    # These arbitrary width networks are obtained by generating sufficiently
    # large base networks and ignoring any excess wires at high positions.
    # The depths of the resulting networks are generally the same as those of
    # the base networks.
    def to_scheme_flexible : Scheme
      FlexibleFromPw2.new(self)
    end
  end

  def_scheme_children @scheme

  def initialize(@scheme : S)
  end

  def network(width : Width)
    pw2 = width.value == 0 ? Width.from_pw2(Distance.new(1)) : width.to_pw2
    Network::WidthSlice.new(@scheme.network(pw2), width.value)
  end
end
