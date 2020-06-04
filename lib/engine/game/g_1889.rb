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

      DEV_STAGE = :production

      def operating_round(round_num)
        # 1889 is more unusual than 1846, 1882 and 18Chesapeake in that it doesn't
        # allow other presidency shifts nor buying other players trains for up to face value
        Round::Operating.new(
          @corporations.select(&:floated?).sort,
          game: self,
          round_num: round_num,
          num_rounds: @operating_rounds,
          ebuy_pres_swap: false,
          ebuy_other_value: false
        )
      end
    end
  end
end
