require "../gate_options"

struct PBTranslator::Scheme::IndexableComparator(T)
  include GateOptions::Module

  declare_gate_options

  def initialize(@unique_network : Network::IndexableComparator(T))
  end

  def network(width w : Width)
    @unique_network.tap do |n|
      e = n.network_width
      next if e == w.value
      raise "Requested width #{w.value} is not #{e}"
    end
  end
end
