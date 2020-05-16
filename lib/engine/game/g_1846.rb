# File original exported from 18xx-maker: https://www.18xx-maker.com/
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# frozen_string_literal: true

require_relative '../config/game/g_1846'
require_relative 'base'

module Engine
  module Game
    class G1846 < Base
      load_from_json(Config::Game::G1846::JSON)
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
