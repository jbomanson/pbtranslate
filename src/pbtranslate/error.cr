module PBTranslate
  # An error specific to PBTranslate.
  class Error < Exception
  end

  # An error raised when something supposedly impossible has happened.
  class ImpossibleError < Error
  end
end
