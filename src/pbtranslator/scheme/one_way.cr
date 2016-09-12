module PBTranslator
  # A OneWay scheme represents some class of networks that operates on a
  # contiguous range of _wires_.
  #
  # The gates in such a network involve only those wires.
  abstract class Scheme::OneWay
    # Returns a network with a number of wires that is a power of two.
    abstract def network(width_log2)
  end
end
