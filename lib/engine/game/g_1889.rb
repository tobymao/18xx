# frozen_string_literal: true

require_relative '../config/game/g_1889'
require_relative 'base'

module Engine
  module Game
    class G1889 < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1889::JSON)

      DEV_STAGE = :beta
    end
  end
end
