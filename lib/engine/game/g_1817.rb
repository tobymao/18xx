# frozen_string_literal: true

require_relative '../config/game/g_1817'
require_relative 'base'

module Engine
  module Game
    class G1817 < Base
      load_from_json(Config::Game::G1817::JSON)
    end
  end
end
