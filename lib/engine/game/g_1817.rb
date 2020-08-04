# frozen_string_literal: true

require_relative '../config/game/g_1817'
require_relative 'base'

module Engine
  module Game
    class G1817 < Base
      register_colors(black: '#0a0a0a',
                      blue: '#0a70b3',
                      brightGreen: '#7bb137',
                      brown: '#881a1e',
                      gold: '#e09001',
                      gray: '#9a9a9d',
                      green: '#008f4f',
                      lavender: '#baa4cb',
                      lightBlue: '#37b2e2',
                      lightBrown: '#b58168',
                      lime: '#bdbd00',
                      navy: '#004d95',
                      natural: '#fbf4de',
                      orange: '#eb6f0e',
                      pink: '#ec767c',
                      red: '#dd0030',
                      turquoise: '#235758',
                      violet: '#4d2674',
                      white: '#ffffff',
                      yellow: '#fcea18')

      load_from_json(Config::Game::G1817::JSON)

      GAME_LOCATION = 'NYSE, USA'
      GAME_RULES_URL = 'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view'
      GAME_DESIGNER = 'Craig Bartell, Tim Flowers'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1817'

      # @todo: this needs purchase of the 8 train
      GAME_END_CHECK = { bankrupt: :immediate }.freeze

      attr_reader :loans_taken, :loans_available, :loan_increments

      def bankruptcy_limit_reached?
        @players.reject(&:bankrupt).one?
      end

      def init_bank
        @loans_taken = 31
        @loans_available = 14 * 5
        @loan_increments = 100
        super
      end

      def interest_rate
        # @todo: this needs the OR to fix the price.
        @interest_fixed || [[5, ((@loans_taken + 4) / 5).to_i * 5].max, 70].min
      end

      def interest_payable(entity)
        (interest_rate * entity.taken_loans * @loan_increments) / 100
      end
    end
  end
end
