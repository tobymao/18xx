# frozen_string_literal: true

require_relative 'marker'

module Engine
  class Token
    include Marker
    attr_reader :corporation, :price

    def initialize(corporation, price: 0)
      @corporation = corporation
      @price = price
      @used = false
    end
  end
end
