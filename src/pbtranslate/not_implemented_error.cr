class PBTranslate::NotImplementedError < Exception
  def initialize(message = "Not implemented")
    super(message)
  end
end
