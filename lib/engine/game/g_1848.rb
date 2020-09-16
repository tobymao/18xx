# frozen_string_literal: true

require_relative '../config/game/g_1848'
require_relative 'base'

module Engine
  module Game
    class G1848 < Base
      load_from_json(Config::Game::G1848::JSON)
    end
  end
end
