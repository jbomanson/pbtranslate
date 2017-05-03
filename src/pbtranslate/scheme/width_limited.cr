require "../scheme"

struct PBTranslate::Scheme::WidthLimited(S)
  include Scheme
  include OfAnyWidthMarker

  delegate gate_options, to: @scheme

  def initialize(@scheme : S)
  end

  def network(width : Width)
    Network::WidthSlice.new(@scheme.network(width.to_pw2), width.value)
  end
end
