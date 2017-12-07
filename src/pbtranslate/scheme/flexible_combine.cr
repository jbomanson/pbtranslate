# A module for schemes of networks that perform some combination operation on a
# pair of sequences of flexible lengths as opposed to only lengths that are
# powers of two.
#
# The intended use case for these schemes is to provide the combination
# operation used in divide and conquer algorithms to combine the results of
# subproblems.
module PBTranslate::Scheme::FlexibleCombine
  # Generates a network that combines pairs of sequences of the given *widths*
  # that are possibly distinct.
  abstract def network(widths : {Width, Width})
end
