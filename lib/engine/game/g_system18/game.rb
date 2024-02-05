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
        CURRENCY_FORMAT_STR = '$%s'

        MUST_SELL_IN_BLOCKS = false
        MUST_BID_INCREMENT_MULTIPLE = true
        ONLY_HIGHEST_BID_COMMITTED = true
        HOME_TOKEN_TIMING = :operate
        SELL_BUY_ORDER = :sell_buy_sell
        GAME_END_CHECK = { bankrupt: :immediate, final_phase: :full_or }.freeze
        LAYOUT = :pointy

        # need to define constants that could be redefined
        SELL_AFTER = :first
        SELL_MOVEMENT = :down_share
        SOLD_OUT_INCREASE = true
        EBUY_EMERGENCY_ISSUE_BEFORE_EBUY = false
        BANKRUPTCY_ENDS_GAME_AFTER = :one

        def map?(map)
          full = "map_#{map}"
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

        def half_dividend_by_map?
          @half_dividend ||= capitalization_by_map == :incremental
        end

        def redef_const(const, value)
          mod = is_a?(Module) ? self : self.class
          mod.send(:remove_const, const) if mod.const_defined?(const)
          mod.const_set(const, value)
        end

        def setup
          #################################################
          # "Standard" overrides for Incremental Cap games
          #
          if capitalization_by_map == :incremental
            redef_const(:SELL_BUY_ORDER, :sell_buy)
            redef_const(:HOME_TOKEN_TIMING, :float)
            redef_const(:SELL_AFTER, :after_ipo)
            redef_const(:SELL_MOVEMENT, :left_block_pres)
            redef_const(:SOLD_OUT_INCREASE, false)
            redef_const(:EBUY_EMERGENCY_ISSUE_BEFORE_EBUY, true)
            redef_const(:BANKRUPTCY_ENDS_GAME_AFTER, :all_but_one)
          end

          #################################################
          # Map-specific overrides
          #
          redef_const(:CURRENCY_FORMAT_STR, 'F%s') if map?(:France)
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
            GSystem18::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
