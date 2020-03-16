# frozen_string_literal: true

require 'engine/passer'
require 'engine/share_holder'
require 'engine/spender'

module Engine
  class Player
    include Passer
    include ShareHolder
    include Spender

    attr_reader :name, :companies

    def initialize(name)
      @name = name
      @cash = 0
      @companies = []
    end

    def id
      @name
    end

    def owner
      self
    end

    def player
      self
    end

    def ==(other)
      @name == other.name
    end
  end
end
