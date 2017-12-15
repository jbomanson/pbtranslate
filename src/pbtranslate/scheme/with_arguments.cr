require "../error"
require "../scheme"
require "../util/type_to_value"

# A module for schemes with `network` and `network?` methods with an argument of
# type *A*.
module PBTranslate::Scheme::WithArguments(A)
  # Returns a potentially uninitialized sample argument of the type expected by
  # `network` for use in typeof expressions.
  def network_arguments_for_typeof
    Util.type_to_value(A)
  end

  # Returns a `Network`.
  #
  # By default, this calls `network?` and raises an `UndefinedNetworkError`
  # if it returns nil.
  # Every subclass should override one or both of `network` and `network?`.
  def network(argument : A) : Network
    network?(argument) || raise UndefinedNetworkError.new(argument)
  end

  # Returns a `Network` or nil.
  #
  # By default this calls `network`.
  # Every subclass should override one or both of `network` and `network?`.
  def network?(argument : A) : Network | Nil
    network
  end
end
