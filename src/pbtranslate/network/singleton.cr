require "../network"

module PBTranslate::Network
  # Creates a network consisting of the given *gate* with the given *options*.
  def self.singleton(gate, **options) : Network
    Singleton.new({gate, options})
  end
end

private struct Singleton(G)
  include PBTranslate::Network

  def initialize(@gate_with_options : G)
  end

  def host_reduce(visitor, memo)
    gate, options = @gate_with_options
    visitor.visit_gate(gate, memo, **options)
  end
end
