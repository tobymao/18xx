# frozen_string_literal: true

require_relative '../config/game/g_1889'
require_relative 'base'

module Engine
  module Game
    class G1889 < Base
      include Config::Game::G1889
    end
  end
end
