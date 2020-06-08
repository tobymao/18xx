# File original exported from 18xx-maker: https://www.18xx-maker.com/
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# frozen_string_literal: true

require_relative '../config/game/g_1846'
require_relative 'base'
require_relative '../publisher/gmt_games.rb'

module Engine
  module Game
    class G1846 < Base
      register_colors(red: '#d1232a',
                      orange: '#f58121',
                      black: '#110a0c',
                      blue: '#025aaa',
                      lightBlue: '#8dd7f6',
                      yellow: '#ffe600',
                      green: '#32763f')

      load_from_json(Config::Game::G1846::JSON)

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'Midwest, USA'
      GAME_RULES_URL = 'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf'
      GAME_DESIGNER = 'Thomas Lehmann'
      GAME_PUBLISHER = Publisher::GmtGames

      SELL_AFTER = :p_any_operate
      SELL_MOVEMENT = :left_block_pres
      HOME_TOKEN_TIMING = :float

      ORANGE_GROUP = [
        'Lake Shore Line',
        'Michigan Central',
        'Ohio & Indiana',
      ].freeze

      BLUE_GROUP = [
        'Steamboat Company',
        'Meat Packing Company',
        'Tunnel Blasting Company',
      ].freeze

      GREEN_GROUP = %w[C&O ERIE PRR].freeze

      def init_companies(players)
        companies = super + @players.size.times.map do |i|
          Company.new(name: (i + 1).to_s, value: 0, desc: "Choose this card if you don't want to purchase a company")
        end

        remove_from_group!(ORANGE_GROUP, companies)
        remove_from_group!(BLUE_GROUP, companies)

        companies
      end

      def remove_from_group!(group, entities)
        remove = group.sort_by { rand }.take([5 - @players.size, 2].min)
        @log << "Removing #{remove.join(', ')}"
        entities.reject! { |e| remove.include?(e.name) }
      end

      def init_corporations(stock_market)
        corporations = super
        remove_from_group!(GREEN_GROUP, companies)
        corporations
      end

      def init_round
        Round::G1846::Draft.new(@players.reverse, game: self)
      end

      def stock_round
        Round::Stock.new(@players, game: self, sell_buy_order: :sell_buy)
      end

      def operating_round(round_num)
        Round::G1846::Operating.new(@corporations, game: self, round_num: round_num)
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
