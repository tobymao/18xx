# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'market'
require_relative 'trains'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module GSystem18
      class Game < Game::Base
        include_meta(GSystem18::Meta)
        include Entities
        include Map
        include Market
        include Trains

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '$%s'

        def setup
          if map?(:France)
            Engine::Game::GSystem18::const_set(:SELL_BUY_ORDER, :sell_buy)
          end
        end

        def map?(map)
          full = "map_#{map.to_str}"
          optional_rules&.include?(full.to_sym)
        end

        def init_starting_cash(players, bank)
          cash = cash_by_map[players.size]
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def init_cert_limit
          certs_by_map[players.size]
        end

        def init_corporations(stock_market)
          game_corporations.map do |corporation|
            self.class::CORPORATION_CLASS.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: capitalization_by_map,
              **corporation.merge(corporation_opts),
            )
          end
        end

        def location_name(coord)
          @location_names ||= game_location_names

          @location_names[coord]
        end

        def multiple_buy_only_from_market?
          !optional_rules&.include?(:multiple_brown_from_ipo)
        end

        def init_round
          return super unless game_companies.empty?

          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter = 1
          stock_round
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
