# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'map'
require_relative 'entities'
require_relative '../../round/operating'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G1835
      class Game < Game::Base
        attr_accessor :draft_finished

        include_meta(G1835::Meta)
        include CitiesPlusTownsRouteDistanceStr
        include G1835::Entities
        include G1835::Map

        register_colors(black: '#37383a',
                        seRed: '#f72d2d',
                        bePurple: '#2d0047',
                        peBlack: '#000',
                        beBlue: '#c3deeb',
                        heGreen: '#78c292',
                        oegray: '#6e6966',
                        weYellow: '#ebff45',
                        beBrown: '#54230e',
                        gray: '#6e6966',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        CURRENCY_FORMAT_STR = '%sM'
        # game end current or, when the bank is empty
        GAME_END_CHECK = { bank: :current_or }.freeze
        # bankrupt is allowed, player leaves game
        BANKRUPTCY_ALLOWED = true

        BANK_CASH = 12_000
        PAR_PRICES = {
          'PR' => 154,
          'BY' => 92,
          'SX' => 88,
          'BA' => 84,
          'WT' => 84,
          'HE' => 84,
          'MS' => 80,
          'OL' => 80,
        }.freeze
        CERT_LIMIT = { 3 => 19, 4 => 15, 5 => 12, 6 => 11, 7 => 9 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 475, 5 => 390, 6 => 340, 7 => 310 }.freeze
        # money per initial share sold
        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        TOKEN_PLACEMENT_ON_TILE_LAY_ENTITY = :owner

        MARKET = [['', '', '', ''] + %w[132 148 166 186 208 232 258 286 316 348 382 418],
                  ['', ''] + %w[98 108 120 134 150 168 188 210 234 260 288 318 350 384],
                  %w[82 86 92p 100 110 122 136 152 170 190 212 236 262 290 320],
                  %w[78 84p 88p 94 102 112 124 138 154p 172 192 214], %w[72 80p 86 90 96 104 114 126 140],
                  %w[64 74 82 88 92 98 106],
                  %w[54 66 76 84 90]].freeze

        PHASES = [
          {
            name: '1.1',
            on: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '1.2',
            on: '2+2',
            train_limit: { minor: 2, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2.1',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.2',
            on: '3+3',
            train_limit: { major: 4, minor: 2 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.3',
            on: '4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '2.4',
            on: '4+4',
            train_limit: { prussian: 4, major: 3, minor: 1 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3.1',
            on: '5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            events: { close_companies: true },
          },
          {
            name: '3.2',
            on: '5+5',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.3',
            on: '6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '3.4',
            on: '6+6',
            train_limit: { prussian: 3, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        def self.plus_train_distance(distance)
          [{ 'nodes' => ['town'], 'pay' => distance, 'visit' => distance },
           { 'nodes' => %w[city offboard town], 'pay' => distance, 'visit' => distance }]
        end

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 9 },
                  { name: '2+2', distance: plus_train_distance(2), price: 120, rusts_on: '4+4', num: 4 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 4 },
                  { name: '3+3', distance: plus_train_distance(3), price: 270, rusts_on: '6+6', num: 3 },
                  { name: '4', distance: 4, price: 360, num: 3 },
                  { name: '4+4', distance: plus_train_distance(4), price: 440, num: 1 },
                  { name: '5', distance: 5, price: 500, num: 2 },
                  { name: '5+5', distance: plus_train_distance(5), price: 600, num: 1 },
                  { name: '6', distance: 6, price: 600, num: 2 },
                  { name: '6+6', distance: plus_train_distance(6), price: 720, num: 4 }].freeze

        LAYOUT = :pointy

        SELL_MOVEMENT = :down_block

        HOME_TOKEN_TIMING = :float

        def setup
          # Reserve Preußen shares to be exchanged for Vorpreußen and Privates
          # Reserving the president share would be correct here, but that would make can_buy and process_buy_shares
          # really complicated. Instead, the president share can be bought and will be swapped for a 10% share
          # once PR floats.
          corporation_by_id('PR').shares.last(8).each { |s| s.buyable = false }

          @corporations.each do |corp|
            corp.shares.reject(&:president).each { |share| share.double_cert = (share.percent == 20) }
          end

          @draft_finished = false
          @draft_round_num = 1

          @corporations.select { |corp| corp.type == :major }.each do |corp|
            @stock_market.set_par(corp, @stock_market.par_prices.find { |share_price| share_price.price == PAR_PRICES[corp.id] })
          end

          corporation_by_id('BY').ipoed = true
          corporation_by_id('SX').ipoed = true
        end

        def company_header(company)
          return 'MINOR' if '123456'.include?(company.sym)
          return 'SHARE' if company.sym == 'BY_D'

          'PRIVATE COMPANY'
        end

        def init_round
          G1835::Round::Draft.new(self,
                                  [G1835::Step::Draft])
        end

        def new_draft_round
          G1835::Round::Draft.new(self,
                                  [G1835::Step::Draft],)
        end

        def next_round!
          return super if @draft_finished

          clear_programmed_actions
          @round =
            case @round
            when G1835::Round::Draft
              reorder_players
              new_operating_round(@draft_round_num)
            when Engine::Round::Operating
              @draft_round_num += 1
              new_draft_round
            end
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::SpecialTrack,
            G1835::Step::SpecialToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1835::Step::BuyTrain,
          ], round_num: round_num)
        end

        def revenue_for(route, stops)
          super + (hamburg_ferry?(route) ? -10 : 0)
        end

        def revenue_str(route)
          str = super
          str += " (#{format_currency(-10)} Hamburg ferry)" if hamburg_ferry?(route)
          str
        end

        def hamburg_hex
          @hamburg_hex ||= hex_by_id('C11')
        end

        def hamburg_ferry?(route)
          return false unless hamburg_hex.tile.color == :brown
          return false unless route.hexes.include?(hamburg_hex)

          north_edge_used = route.paths.any? { |path| path.tile.hex == hamburg_hex && [2, 3, 4].intersect?(path.exits) }
          south_edge_used = route.paths.any? { |path| path.tile.hex == hamburg_hex && [0, 1, 5].intersect?(path.exits) }
          north_edge_used && south_edge_used
        end
      end
    end
  end
end
