module PBTranslator

  # A Scheme represents a circuit or a network of gates.
  #
  # It has a size that is the number of gates in the network.
  # It has a depth that is the number of gates on the longest path from an
  # input to an output.
  #
  # Networks belonging to a scheme are parametrized by some property.
  abstract class Scheme

    # Returns the size of a network parametrized by `param`.
    abstract def size(param)

    # Returns the depth of a network parametrized by `param`.
    abstract def depth(param)
  end
end
