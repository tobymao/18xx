# frozen_string_literal: true

require_relative '../config/game/g_18_chesapeake'
require_relative 'base'

module Engine
  module Game
    class G18Chesapeake < Base
      load_from_json(Config::Game::G18Chesapeake::JSON)
    end
  end
end
