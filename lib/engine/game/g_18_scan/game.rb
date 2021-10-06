# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Scan
      class Game < Game::Base
        include_meta(G18Scan::Meta)
        include G18Scan::Map
        include G18Scan::Entities
      end
    end
  end
end
