require "../scheme"

# A scheme that wraps a single `Network::IndexableComparator`, which it
# returns when `network` is called with the width of the network.
#
# Requesting for networks of other widths is an error.
struct PBTranslate::Scheme::IndexableComparator(T)
  include Scheme

  declare_gate_options

  # Wraps *unique_network* into a `Scheme`.
  def initialize(@unique_network : Network::IndexableComparator(T))
  end

  # Returns the wrapped network if it is of the given `width` and otherwise
  # raises an error.
  def network(width w : Width)
    @unique_network.tap do |n|
      e = n.network_width
      next if e == w.value
      raise "Requested width #{w.value} is not #{e}"
    end
  end
end
