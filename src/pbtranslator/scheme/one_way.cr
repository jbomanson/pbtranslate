require "../scheme"

module PBTranslator
  # A OneWay scheme represents some class of networks that operates on a
  # contiguous range of *wires*.
  #
  # The gates in such a network involve only those wires.
  abstract class Scheme::OneWay < Scheme

    # Performs a visit on the gates in a network corresponding to the parameter
    # value *param*.
    #
    # Each gate is visited in turn to some method of *visitor*.
    # All visited wires will be at a given *offset*.
    abstract def visit(param, offset, visitor)

    # Performs a reverse visit.
    #
    # See `#visit`.
    abstract def reverse_visit(param, offset, visitor)
  end
end
