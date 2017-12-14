require "../error"
require "../util"

module PBTranslate::Util
  # Returns a sample instance of a type for use in typeof expressions.
  #
  # An error is raised if this method is called.
  #
  # ### Example
  #
  # ```
  # include PBTranslate::Util
  #
  # typeof(type_to_value(Int32))      # => Int32
  # typeof(type_to_value(Int32).to_s) # => String
  #
  # type_to_value(Int32) # => Error
  # ```
  def type_to_value(type : U.class) : U forall U
    raise Error.new("type_to_value is for typeof expressions only")
    y = uninitialized U
  end
end
