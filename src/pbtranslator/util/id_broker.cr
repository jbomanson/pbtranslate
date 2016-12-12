module PBTranslator::Util
  # A brokered id.
  struct BrokeredId(T)
    getter brokered_id

    def initialize(@brokered_id : T)
    end

    def operate : self
      self.class.new(yield @brokered_id)
    end
  end

  # A class for renaming and generating integer identifiers.
  #
  # The output integers start from zero.
  # This class is tuned for cases where the input integers to be renamed are
  # mostly contiguous and begin from around zero.
  class IdBroker
    private module Chunk
      SHIFT = 8
      SIZE  = 1 << SHIFT
      MASK  = SIZE - 1
    end

    # Creates a new broker.
    def initialize
      @chunks = Array(UInt32).new
      @chunk_counter = 0_u32
      @anonymous_chunk = 0_u32
      @anonymous_counter = 0
    end

    # Returns a new Int32 based identifier.
    def fresh_id : BrokeredId(Int32)
      fresh_id(Int32)
    end

    # Returns a new identifier of the given _type_.
    def fresh_id(type : T.class) : BrokeredId(T)
      chunk = @anonymous_chunk
      counter = @anonymous_counter
      if counter & Chunk::MASK == 0
        chunk = @anonymous_chunk = new_chunk
        counter = @anonymous_counter = 0
      end
      @anonymous_counter += 1
      combine(chunk, counter, type)
    end

    # Returns a new or an existing Int32 based identifier unique to _key_.
    def rename(key) : BrokeredId(Int32)
      rename(key, Int32)
    end

    # Returns a new or an existing identifier of _type_ unique to _key_.
    def rename(key, type : T.class) : BrokeredId(T)
      quotient = key >> Chunk::SHIFT
      remainder = key & Chunk::MASK
      chunk = chunk_for(quotient)
      combine(chunk, remainder, type)
    end

    private def chunk_for(quotient)
      @chunks.size.upto(quotient) do
        @chunks << new_chunk
      end
      @chunks[quotient]
    end

    private def combine(chunk, remainder, type : T.class) : BrokeredId(T) forall T
      BrokeredId.new(((T.zero + chunk) << Chunk::SHIFT) | remainder)
    end

    private def new_chunk
      c = @chunk_counter
      @chunk_counter += 1
      c
    end

  end
end
