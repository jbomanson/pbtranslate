abstract struct PBTranslator::Width(I)
  def self.from_log2(l)
    Pw2.new(log2: l)
  end

  def self.from_pw2(p)
    Pw2.new(pw2: p)
  end

  def self.from_value(v)
    Free.new(value: v)
  end

  struct Pw2(I) < Width(I)
    getter log2

    def self.new(*, pw2 : I) forall I
      new(log2: I.zero + (pw2 - 1).popcount)
    end

    def self.new(*, value) 
      new(pw2: Math.pw2ceil(value))
    end

    def initialize(*, @log2 : I)
    end

    def pw2
      (I.zero + 1) << log2
    end

    def value
      pw2ceil
    end

    def to_pw2
      self
    end

    def to_free
      Free.new(value: value)
    end

    def log2ceil
      log2
    end

    def pw2ceil
      pw2
    end
  end

  struct Free(I) < Width(I)
    getter value

    def initialize(*, @value : I)
    end

    def pw2ceil
      Math.pw2ceil(value)
    end

    def log2ceil
      to_pw2.log2ceil
    end

    def to_pw2
      Pw2.new(value: value)
    end

    def to_free
      self
    end
  end
end
