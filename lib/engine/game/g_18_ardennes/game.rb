# frozen_string_literal: true

require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'market'
require_relative 'meta'
require_relative 'tiles'
require_relative 'trains'

module Engine
  module Game
    module G18Ardennes
      class Game < Game::Base
        include_meta(G18Ardennes::Meta)
        include Entities
        include Map
        include Market
        include Tiles
        include Trains

        def reservation_corporations
          minors + corporations
        end
      end
    end
  end
end
