# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'

module Engine
  module Game
    module G2038
      class Game < Game::Base
        include_meta(G2038::Meta)
        include Map
        include Entities

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#ccdeee',
                        lightBlue: '#e0ebf4',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :p_any_operate
        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 10_000

        CERT_LIMIT = { 3 => 22, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        HOME_TOKEN_TIMING = :never

        MARKET = [
          %w[71 80 90 101 113 126 140 155 171 188 206 225 245 266 288 311 335 360 386 413 441 470 500],
          %w[62 70 79 89 100p 112 125x 139 154 170 187 205 224 244 265 287 310 334 359 385 412 440 469],
          %w[54 61 69 78 88p 99 111 124 138 153 169 186 204 223 243 264],
          %w[46 53 60 68 77p 87 98 110 123 137 152 168 185],
          %w[36 45 52 59 67p 76 86 97 109 122 136],
          %w[24 35 44 51 58 66 75 85 96],
          %w[10z 23 34 43 50 57 65],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par: 'Public Corps Par',
          par_1: 'Asteroid League Par',
          par_2: 'All Growth Corps Par',
        )

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par: :grey,
          par_1: :brown,
          par_2: :blue,
        )

        PHASES = [
          {
            name: '1',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '2',
            on: '4dc3',
            train_limit: 4,
            tiles: %i[yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '3',
            on: '5dc4',
            train_limit: 3,
            tiles: %i[yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '6d5c',
            train_limit: 3,
            tiles: %i[yellow gray],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '7d6c',
            train_limit: 3,
            tiles: %i[yellow gray],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '9d7c',
            train_limit: 2,
            tiles: %i[yellow gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: 'probe',
            distance: 4,
            price: 1,
            rusts_on: %w[4dc3 6d2c],
            num: 1,
          },
          {
            name: '3dc2',
            distance: 3,
            price: 100,
            rusts_on: %w[5dc4 7d3c],
            num: 10,
            variants: [
              {
                name: '5dc1',
                rusts_on: %w[5dc4 7d3c],
                distance: 5,
                price: 100,
              },
            ],
          },
          {
            name: '4dc3',
            distance: 4,
            price: 200,
            rusts_on: %w[7d6c 9d5c],
            num: 10,
            variants: [
              {
                name: '6d2c',
                rusts_on: %w[7d6c 9d5c],
                distance: 6,
                price: 175,
              },
            ],
          },
          {
            name: '5dc4',
            distance: 5,
            price: 325,
            rusts_on: 'D',
            num: 6,
            variants: [
              {
                name: '7d3c',
                distance: 7,
                price: 275,
              },
            ],
            events: [{ 'type' => 'asteroid_league_can_form' }],
          },
          {
            name: '6d5c',
            distance: 6,
            price: 450,
            num: 5,
            variants: [
              {
                name: '8d4c',
                distance: 8,
                price: 400,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '7d6c',
            distance: 7,
            price: 600,
            num: 2,
            variants: [
              {
                name: '9d5c',
                distance: 9,
                price: 550,
              },
            ],
          },
          {
            name: '9d7c',
            distance: 9,
            price: 950,
            num: 9,
            discount: {
              '5dc4' => 700,
              '7d3c' => 700,
              '6d5c' => 700,
              '8d4c' => 700,
              '7d6c' => 700,
              '9d5c' => 700,
            },
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'asteroid_league_can_form' => ['Asteroid League may be formed'],
          'group_b_corps_available' => ['Group B Corporations become available'],
          'group_c_corps_available' => ['Group C Corporations become available'],
        ).freeze

        def bank_starting_cash
          optional_short_game ? 4_000 : BANK_CASH
        end

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G2038::Step::WaterfallAuction,
          ])
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def setup
          @al_corporation = corporation_by_id('AL')
          @al_corporation.capitalization = :incremental

          @corporations.reject! { |c| c.id == 'AL' }

          return if optional_variant_start_pack

          @available_corp_group = :group_a

          @corporations, @b_group_corporations = @corporations.partition do |corporation|
            corporation.type == :group_a
          end

          @b_group_corporations, @c_group_corporations = @b_group_corporations.partition do |corporation|
            corporation.type == :group_b
          end
        end

        def event_group_b_corps_available!
          @log << 'Group B corporations are now available'

          @corporations.concat(@b_group_corporations)
          @b_group_corporations = []
          @available_corp_group = :group_b
        end

        def event_group_c_corps_available!
          @log << 'Group C corporations are now available'

          @corporations.concat(@c_group_corporations)
          @c_group_corporations = []
          @available_corp_group = :group_c
        end

        def event_asteroid_league_can_form!
          @log << 'Asteroid League may now be formed'
          @corporations << @al_corporation
        end

        def event_asteroid_league_formed!
          @log << 'Asteroid League has formed'
        end

        def company_header(company)
          is_minor = @minors.find { |m| m.id == company.id }

          if is_minor
            'INDEPENDENT COMPANY'
          else
            'PRIVATE COMPANY'
          end
        end

        def after_par(corporation)
          super

          return unless @corporations.all?(&:ipoed)

          case @available_corp_group
          when :group_a
            event_group_b_corps_available!
          when :group_b
            event_group_c_corps_available!
          end
        end

        def after_buy_company(player, company, _price)
          target_price = optional_short_game ? 67 : 100
          share_price = stock_market.par_prices.find { |pp| pp.price == target_price }

          # NOTE: This should only ever be TSI
          abilities(company, :shares) do |ability|
            ability.shares.each do |share|
              if share.president
                stock_market.set_par(share.corporation, share_price)
                share_pool.buy_shares(player, share, exchange: :free)
                after_par(share.corporation)
              else
                share_pool.buy_shares(player, share, exchange: :free)
              end
            end
          end
        end

        def optional_short_game
          @optional_rules&.include?(:optional_short_game)
        end

        def optional_variant_start_pack
          @optional_rules&.include?(:optional_variant_start_pack)
        end
      end
    end
  end
end
