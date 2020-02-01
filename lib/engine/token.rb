# frozen_string_literal: true

module Engine
  class Token
    attr_reader :corporation

    def initialize(corporation, placed = false)
      @corporation = corporation
      @placed = placed
    end

    def place!
      @placed = true
    end

    def unplaced?
      !@placed
    end

    def ==(other)
      (other.class == Token) && (unplaced? == other.unplaced?) && (@corporation.sym == other.corporation.sym)
    end
  end
end
