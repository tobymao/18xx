# frozen_string_literal: true

require_relative '../config/game/g_18_carolinas'
require_relative 'base'

module Engine
  module Game
    class G18Carolinas < Base
      load_from_json(Config::Game::G18Carolinas::JSON)
    end
  end
end
