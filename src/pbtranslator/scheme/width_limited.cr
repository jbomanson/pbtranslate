struct PBTranslator::Scheme::WidthLimited(S)
  def initialize(@scheme : S)
  end

  def network(width : Width::Free)
    Network::WidthLimited.new(@scheme.network(width.to_pw2), width.value)
  end
end
