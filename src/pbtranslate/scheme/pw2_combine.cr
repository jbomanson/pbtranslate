require "./with_arguments"

# A module for schemes of networks that perform some operation on a pair of
# sequences of equal lengths that are powers of two.
#
# The intended use case for these schemes is to provide the combination
# operation in divide and conquer algorithms that combines the results of
# subproblems.
module PBTranslate::Scheme::Pw2Combine
  include Scheme::WithArguments(Width::Pw2)

  # Generates a network that performs an operation on a pair of sequences each
  # of length *half_width*.
  abstract def network(half_width : Width::Pw2)
end
