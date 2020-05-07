# frozen_string_literal: true

require_relative '../config/game/g_18_chesapeake'
require_relative 'base'

module Engine
  module Game
    class G18Chesapeake < Base
      include Config::Game::G18Chesapeake
    end
  end
end
