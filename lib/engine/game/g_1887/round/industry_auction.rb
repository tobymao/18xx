# frozen_string_literal: true

require_relative '../../../round/auction'

module Engine
  module Game
    module G1887
      module Round
        class IndustryAuction < Engine::Round::Auction
          def name
            'Industry Auction'
          end

          def self.short_name
            'IA'
          end
        end
      end
    end
  end
end
