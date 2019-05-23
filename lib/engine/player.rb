# frozen_string_literal: true

require 'engine/passer'
require 'engine/spender'

module Engine
  class Player
    include Passer
    include Spender

    attr_reader :name, :companies, :shares

    def initialize(name)
      @name = name
      @cash = 0
      @shares = []
      @companies = []
      @passed = false
    end

    def player
      self
    end
  end
end
