# A module for schemes of networks that perform some operation on a pair of
# sequences of equal lengths that are powers of two.
#
# The intended use case for these schemes is to provide the conquer operation
# in divide and conquer algorithms.
module PBTranslate::Scheme::Pw2Conquer
  # Generates a network that performs an operation on a pair of sequences each
  # of length *half_width*.
  abstract def network(half_width : Width::Pw2)
end
