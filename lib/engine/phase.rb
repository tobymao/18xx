# frozen_string_literal: true

module Engine
  class Phase
    attr_reader :name, :operating_rounds, :train_limit, :tiles

    def self.yellow
      new('Yellow')
    end

    def self.green
      new('Green', operating_rounds: 2, train_limit: 3, tiles: %i[yellow green])
    end

    def self.brown
      new(
        'Brown',
        operating_rounds: 3,
        train_limit: 2,
        tiles: %i[yellow green brown],
      )
    end

    def initialize(name, operating_rounds: 1, train_limit: 4, tiles: :yellow)
      @name = name
      @operating_rounds = operating_rounds
      @train_limit = train_limit
      @tiles = Array(tiles)
    end
  end
end
