# frozen_string_literal: true

module Engine
  class Token
    attr_reader :corporation

    def initialize(corporation)
      @corporation = corporation
    end

    def ==(other)
      other.class == Token && @corporation.sym == other.corporation.sym
    end
  end
end
