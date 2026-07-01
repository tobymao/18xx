# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'
require_relative 'round/operating'
require_relative 'step/waterfall_auction'
require_relative 'step/buy_train'
require_relative 'step/dividend'

module Engine
  module Game
    module G2038
      class Game < Game::Base
        include_meta(G2038::Meta)
        include Map
        include Entities

        TILE_TYPE = :lawson
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

        MINOR_OPERATING_ORDER = %w[FB IF DH OC TH LY].freeze
        ENTITY_DISPLAY_ORDER = %w[FB IF DH OC TH LY TSI RU VP LE MM OPC RCC AL].freeze

        ORE_COLORS = {
          N: '#888888',
          I: '#4499cc',
          R: '#9944cc',
        }.freeze

        PHASES = [
          {
            name: '1',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '2',
            on: '4/3',
            train_limit: 4,
            tiles: %i[yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '3',
            on: '5/4',
            train_limit: 3,
            tiles: %i[yellow],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '4',
            on: '6/5',
            train_limit: 3,
            tiles: %i[yellow gray],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '7/6',
            train_limit: 3,
            tiles: %i[yellow gray],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '9/7',
            train_limit: 2,
            tiles: %i[yellow gray],
            operating_rounds: 2,
          },
        ].freeze

        # Spaceship names are movement/cargo_holds (e.g. '3/2' = 3 MP, 2 cargo holds),
        # matching the physical spaceship card naming. cargo_holds: is stored in
        # Train#@opts by the base engine; a custom Train subclass will expose it properly.
        TRAINS = [
          {
            name: 'probe',
            distance: 4,
            cargo_holds: 0,
            price: 1,
            rusts_on: %w[4/3 6/2],
            num: 1,
          },
          {
            name: '3/2',
            distance: 3,
            cargo_holds: 2,
            price: 100,
            rusts_on: %w[5/4 7/3],
            num: 10,
            variants: [
              {
                name: '5/1',
                distance: 5,
                cargo_holds: 1,
                price: 100,
                rusts_on: %w[5/4 7/3],
              },
            ],
          },
          {
            name: '4/3',
            distance: 4,
            cargo_holds: 3,
            price: 200,
            rusts_on: %w[7/6 9/5],
            num: 10,
            variants: [
              {
                name: '6/2',
                distance: 6,
                cargo_holds: 2,
                price: 175,
                rusts_on: %w[7/6 9/5],
              },
            ],
          },
          {
            name: '5/4',
            distance: 5,
            cargo_holds: 4,
            price: 325,
            rusts_on: 'D',
            num: 6,
            variants: [
              {
                name: '7/3',
                distance: 7,
                cargo_holds: 3,
                price: 275,
                rusts_on: 'D',
              },
            ],
            events: [{ 'type' => 'asteroid_league_can_form' }],
          },
          {
            name: '6/5',
            distance: 6,
            cargo_holds: 5,
            price: 450,
            num: 5,
            variants: [
              {
                name: '8/4',
                distance: 8,
                cargo_holds: 4,
                price: 400,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '7/6',
            distance: 7,
            cargo_holds: 6,
            price: 600,
            num: 2,
            variants: [
              {
                name: '9/5',
                distance: 9,
                cargo_holds: 5,
                price: 550,
              },
            ],
          },
          {
            name: '9/7',
            distance: 9,
            cargo_holds: 7,
            price: 950,
            num: 9,
            discount: {
              '5/4' => 700,
              '7/3' => 700,
              '6/5' => 700,
              '8/4' => 700,
              '7/6' => 700,
              '9/5' => 700,
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
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G2038::Step::WaterfallAuction,
          ])
        end

        def new_operating_round(round_num = 1)
          G2038::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::DiscardTrain,
            G2038::Step::Dividend,
            G2038::Step::BuyTrain,
            Engine::Step::BuyCompany,
          ], round_num: round_num)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when G2038::Round::Operating
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

        def bank_sort(entities)
          entities.sort_by { |e| ENTITY_DISPLAY_ORDER.index(e.id) || ENTITY_DISPLAY_ORDER.size }
        end

        def operating_order
          minors = MINOR_OPERATING_ORDER.filter_map { |id| minor_by_id(id) }
          corps = @corporations.select(&:floated?).sort do |a, b|
            if a.share_price.price != b.share_price.price
              b.share_price.price <=> a.share_price.price
            else
              a.share_price.coordinates <=> b.share_price.coordinates
            end
          end
          minors + corps
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
          is_minor ? 'INDEPENDENT COMPANY' : 'PRIVATE COMPANY'
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
