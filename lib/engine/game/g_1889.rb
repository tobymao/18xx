# frozen_string_literal: true

require_relative '../config/game/g_1889'
require_relative 'base'

module Engine
  module Game
    class G1889 < Base
      load_from_json(Config::Game::G1889::JSON)

      DEV_STAGE = :beta
    end
  end
end
