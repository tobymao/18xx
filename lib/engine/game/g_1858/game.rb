# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'market'
require_relative 'trains'
require_relative '../base'

module Engine
  module Game
    module G1858
      class Game < Game::Base
        include_meta(G1858::Meta)
        include G1858::Map
        include G1858::Entities
        include G1858::Market
        include G1858::Trains
        include CitiesPlusTownsRouteDistanceStr

        def setup
          super
        end

        def stock_round
          super
        end

        def operating_round
          super
        end
      end
    end
  end
end
