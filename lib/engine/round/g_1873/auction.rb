# frozen_string_literal: true

require_relative '../auction'

module Engine
  module Round
    module G1873
      class Auction < Auction
        def self.short_name
          'AR'
        end
      end
    end
  end
end
