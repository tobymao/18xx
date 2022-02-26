# frozen_string_literal: true

require_relative '../g_18_los_angeles/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'

module Engine
  module Game
    module G18LosAngeles1
      class Game < G18LosAngeles::Game
        include_meta(G18LosAngeles1::Meta)
        include Entities
        include Map

        def game_companies
          @game_companies ||=
            self.class::COMPANIES + (G18LosAngeles::Game::COMPANIES.slice(0, 11).map do |company|
                                       self.class::COMPANIES_1E[company[:sym]] || company
                                     end)
        end

        def game_corporations
          @game_corporations ||=
            G18LosAngeles::Game::CORPORATIONS.map do |company|
              self.class::CORPORATIONS_1E[company[:sym]] || company
            end
        end
      end
    end
  end
end
