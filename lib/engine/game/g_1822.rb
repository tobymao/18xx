# frozen_string_literal: true

require_relative '../config/game/g_1822'
require_relative 'base'
require_relative 'stubs_are_restricted'

module Engine
  module Game
    class G1822 < Base
      register_colors(lyrPurple: '#2d0047',
                      crBlue: '#5555ff',
                      gwrGreen: '#165016',
                      lbscrYellow: '#cccc00',
                      lnwrBlack: '#000',
                      mrRed: '#ff2a2a',
                      nbrBrown: '#a05a2c',
                      nerGreen: '#aade87',
                      secrOrange: '#ff7f2a',
                      swrGray: '#999999',
                      black: '#000',
                      white: '#ffffff')

      load_from_json(Config::Game::G1822::JSON)

      DEV_STAGE = :prealpha

      SELL_MOVEMENT = :down_share

      GAME_LOCATION = 'Great Britain'
      GAME_RULES_URL = 'http://google.com'
      GAME_DESIGNER = 'Simon Cutforth'
      GAME_PUBLISHER = :all_aboard_games
      GAME_INFO_URL = 'https://google.com'

      HOME_TOKEN_TIMING = :operating_round

      include StubsAreRestricted

      def setup
        # Reserve all the minor cities
        @minors.each do |minor|
          hex = hex_by_id(minor.coordinates)
          hex.tile.add_reservation!(minor, minor.city, nil)
        end

      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::DiscardTrain,
          Step::BuyTrain
        ], round_num: round_num)
      end
    end
  end
end