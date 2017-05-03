# A network implementing this module provides useful introspection methods.
module PBTranslate::Network::FirstClass
  # Returns the number of gates on the longest path from an input to an output.
  abstract def network_depth : Distance

  # Returns the number of input reads by gates in the network.
  abstract def network_read_count : Area

  # Returns the width of the network in wires.
  abstract def network_width : Distance

  # Returns the number of outputs defined by gates in the network.
  abstract def network_write_count : Area
end
