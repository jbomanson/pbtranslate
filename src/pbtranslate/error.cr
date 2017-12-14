module PBTranslate
  # An error specific to PBTranslate.
  class Error < Exception
  end

  # An error raised when something supposedly impossible has happened.
  class ImpossibleError < Error
  end

  # An error raised when `Scheme#network` is called with an argument for which
  # it is not defined.
  #
  # These are the arguments for which `Scheme#network?` would return nil.
  class UndefinedNetworkError < Error
    def initialize(argument)
      super("network(#{argument}) is not defined")
    end
  end
end
