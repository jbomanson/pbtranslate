require "./network_or_scheme"
require "./tuple"

# This module contains schemes for generating networks.
#
# Each scheme represents some class of networks parametrized by some property.
# These networks can generally be instantiated via `#network` or `#network?`
# methods of a scheme.
# These two kinds of network generation methods will raise and return nil
# on errors, respectively.
module PBTranslate::Scheme
  include NetworkOrScheme

  # See `NetworkOrScheme#gate_with_options_for_typeof`.
  def gate_with_options_for_typeof
    network_for_typeof.gate_with_options_for_typeof
  end

  # Returns a potentially uninitialized sample argument of the type expected by
  # `network` for use in typeof expressions.
  abstract def network_arguments_for_typeof

  # Returns a potentially uninitialized sample network for use in typeof
  # expressions.
  def network_for_typeof : Network
    network(network_arguments_for_typeof)
  end

  # Defines `scheme_children`based on given *fields*.
  macro def_scheme_children(*fields)
    def scheme_children
      {{fields}}
    end
  end

  # Implements `#network_arguments_for_typeof`.
  macro delegate_scheme_details_to(*fields)
    def network_arguments_for_typeof
      arguments = {{fields.map { |f| "(#{f}).network_arguments_for_typeof".id }}}
      Util.restrict_tuple_uniform(arguments)
      arguments.first
    end
  end

  # Returns an `Enumerable` of child `Scheme`s that this one depends on.
  def scheme_children
    Tuple.new
  end

  # Returns a `Tuple` with this scheme, its children, their children, etc.
  def scheme_descendants : Tuple
    scheme_children.pbtranslate_reduce_with_receiver(
      SchemeDescendants.new,
      {self},
    )
  end

  # Prints Crystal program code that configures schemes like this one.
  #
  # The default implementation does nothing.
  # Subclasses may override this in order to print something useful.
  def tune_generate(io)
  end

  # Calls `tune_generate` on this scheme and its descendants.
  def tune_generate_recursively(io) : Nil
    io.puts "# This file has been generated with"
    io.puts "# #{PBTranslate::Config.description}."
    io.puts "# It is intended to be at \"src/pbtranslate/scheme/tune.cr\"."
    io.puts
    io.puts "include PBTranslate"
    scheme_descendants.each &.tune_generate(io)
  end

  # Tunes this scheme and its descendants based on static profiling information.
  def tune_recursively : Nil
    scheme_descendants.each { |scheme| Scheme.tune(scheme) }
  end
end

private struct SchemeDescendants
  def call(memo, scheme)
    memo + scheme.scheme_descendants
  end
end

require "./scheme/tune"

module PBTranslate::Scheme
  # :nodoc:
  def Scheme.tune(scheme : Scheme) : Nil
  end
end
