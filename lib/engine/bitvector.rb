# frozen_string_literal: true

module Engine
  class BitVector
    BITS_PER_GROUP = 52 # max safe JS integer size

    def initialize(graph, id)
      @graph = graph
      @id = id
      @next_index = 0
      @vector = []
    end

    def [](target)
      check_and_allocate(target)
      ((@vector[target.bit_group] >> target.bit_index) & 1) == 1
    end

    def []=(target, val)
      check_and_allocate(target)
      bit = val ? 1 : 0
      @vector[target.bit_group] |= (bit << target.bit_index)
    end

    def delete(target)
      check_and_allocate(target)
      @vector[target.bit_group] = (@vector[target.bit_group] | (1 << target.bit_index)) ^ (1 << target.bit_index)
    end

    private

    def check_and_allocate(target)
      if target.walk_graph != @graph || target.walk_id != @id
        target.walk_graph = @graph
        target.walk_id = @id
        target.bit_group = @next_index.div(BITS_PER_GROUP)
        target.bit_index = @next_index % BITS_PER_GROUP
        @next_index += 1
      end
      @vector[target.bit_group] = 0 unless @vector[target.bit_group] # extend if needed
    end
  end
end
