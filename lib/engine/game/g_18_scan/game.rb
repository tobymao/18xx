# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18Scan
      class Game < Game::Base
        include_meta(G18Scan::Meta)
      end
    end
  end
end
