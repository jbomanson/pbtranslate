require "../network/flexible_indexable_comparator"
require "../scheme"

# :nodoc:
struct PBTranslate::Scheme::PartialFlexibleIndexableComparator(T)
  include Scheme

  struct ::PBTranslate::Network::FlexibleIndexableComparator(T)
    # Creates a scheme that wraps this single network which it returns whenever
    # it receives a `network` with the width of the network as an argument.
    #
    # Requests for networks of other widths is an error.
    def to_scheme_singleton : Scheme
      PBTranslate::Scheme::PartialFlexibleIndexableComparator.new(self)
    end
  end

  declare_gate_options

  def initialize(@unique_network : Network::FlexibleIndexableComparator(T))
  end

  def network(width w : Width)
    @unique_network.tap do |n|
      e = n.network_width
      next if e == w.value
      raise "Requested width #{w.value} is not #{e}"
    end
  end
end
