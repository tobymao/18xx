# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G18Ardennes
      module Round
        class Auction < Engine::Round::Auction
          def self.short_name
            'PCA'
          end
        end
      end
    end
  end
end
