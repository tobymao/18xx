# frozen_string_literal: true

require_relative '../config/game/g_1830'
require_relative 'base'

module Engine
  module Game
    class G1830 < Base
      load_from_json(Config::Game::G1830::JSON)
    end
  end
end
