# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1844
      class Game < Game::Base
        include_meta(G1844::Meta)
        include Entities
        include Map

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        CURRENCY_FORMAT_STR = '%s SFR'

        BANK_CASH = 12_000

        CERT_LIMIT = { 3 => 24, 4 => 18, 5 => 15, 6 => 13, 7 => 11 }.freeze
        CERT_LIMIT_INCLUDES_PRIVATES = false

        STARTING_CASH = { 3 => 800, 4 => 620, 5 => 510, 6 => 440, 7 => 400 }.freeze

        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_block
        NEXT_SR_PLAYER_ORDER = :most_cash
        EBUY_PRES_SWAP = false
        MUST_BUY_TRAIN = :always

        TRACK_RESTRICTION = :permissive
        TILE_RESERVATION_BLOCKS_OTHERS = :always

        MARKET = [
        ['',
         '',
         '90',
         '100',
         '110',
         '120',
         '130',
         '140',
         '155',
         '170',
         '185',
         '200',
         '220',
         '240',
         '260',
         '290',
         '320',
         '350'],
        ['',
         '70',
         '80',
         '90',
         '100p',
         '110',
         '120',
         '130',
         '145',
         '160',
         '175',
         '190',
         '210',
         '230',
         '250',
         '280',
         '310',
         '340'],
        %w[55 60 70 80 90p 100 110 120 135 150 165 180 200 220 240 270 300 330],
        %w[50 56 60 70 80p 90 100 110 125 140 155 170 190 210 230],
        %w[45 52 57 60 70p 80 90 100 115 130 145 160],
        %w[40 50 54 58 60p 70 80 90 100 120],
        %w[35 45 52 56 59 64 70 80],
        %w[30 40 48 54 58 60],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: { 'pre-sbb': 2, regional: 2, historical: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { 'pre-sbb': 2, regional: 2, historical: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '4',
            on: '4',
            train_limit: { 'pre-sbb': 2, regional: 2, historical: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '7',
            on: '8E',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            num: 13,
            distance: 2,
            price: 90,
            rusts_on: '4',
            variants: [
              {
                name: '2H',
                distance: 2,
                price: 70,
              },
            ],
          },
          {
            name: '3',
            num: 9,
            distance: 3,
            price: 180,
            rusts_on: '6',
            variants: [
              {
                name: '3H',
                distance: 3,
                price: 150,
              },
            ],
          },
          {
            name: '4',
            num: 6,
            distance: 4,
            price: 300,
            rusts_on: '7',
            variants: [
              {
                name: '4H',
                distance: 4,
                price: 260,
              },
            ],
          },
          {
            name: '5',
            num: 4,
            distance: 5,
            price: 450,
            events: [{ 'type' => 'close_companies' }, { 'type' => 'sbb_formation' }],
            variants: [
              {
                name: '5H',
                distance: 5,
                price: 400,
              },
            ],
          },
          {
            name: '6',
            num: 4,
            distance: 6,
            price: 630,
            events: [{ 'type' => 'full_capitalization' }],
            variants: [
              {
                name: '6H',
                distance: 6,
                price: 550,
              },
            ],
          },
          {
            name: '8E',
            num: 20,
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 8, 'visit' => 99 }],
            price: 960,
            variants: [
              {
                name: '8H',
                distance: 8,
                price: 700,
              },
            ],
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'sbb_formation' => ['SBB Forms', 'SBB forms at end of OR'],
          'full_capitalization' => ['Full Capitalization', 'Newly formed corporations receive full capitalization']
        ).freeze

        def privates
          @privates ||= @companies.select { |c| c.sym[0] == 'P' }
        end

        def mountain_railways
          @mountain_railways ||= @companies.select { |c| c.sym[0] == 'B' }
        end

        def tunnel_companies
          @tunnel_companies ||= @companies.select { |c| c.sym[0] == 'T' }
        end

        def fnm
          @fnm ||= corporation_by_id('FNM')
        end

        def sbb
          @sbb ||= corporation_by_id('SBB')
        end

        def setup
          setup_destinations
          mountain_railways.each { |mr| mr.owner = @bank }
          tunnel_companies.each { |tc| tc.owner = @bank }
        end

        def setup_destinations
          @corporations.each do |c|
            next unless c.destination_coordinates

            dest_hex = hex_by_id(c.destination_coordinates)
            ability = Ability::Base.new(
              type: 'base',
              description: "Destination: #{dest_hex.location_name} (#{dest_hex.name})",
            )
            c.add_ability(ability)

            dest_hex.assign!(c)
          end
        end

        def initial_auction_companies
          privates
        end

        def next_round!
          @round =
            case @round
            when init_round.class
              init_round_finished
              reorder_players(:least_cash, log_player_order: true)
              new_stock_round
            else
              super
            end
        end

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            Engine::Step::SelectionAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1844::Step::BuySellParShares,
          ])
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

        def after_par(corporation)
          super
          return unless corporation.type == :historical

          num_tokens =
            case corporation.share_price.price
            when 100 then 5
            when 90 then 4
            when 80 then 3
            when 70 then 2
            when 60 then 1
            else 0
            end
          corporation.tokens.slice!(num_tokens..-1)
          @log << "#{corporation.name} receives #{num_tokens} token#{num_tokens > 1 ? 's' : ''}"

          return unless corporation == fnm

          @share_pool.transfer_shares(ShareBundle.new(corporation.shares_of(corporation).take(3)), @share_pool)
          @log << "3 #{corporation.name} shares moved to the market"
          float_corporation(corporation)
        end

        def float_corporation(corporation)
          return if corporation == sbb

          @log << "#{corporation.name} floats"
          multiplier = corporation.type == :'pre-sbb' ? 2 : 5
          @bank.spend(corporation.par_price.price * multiplier, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
        end
      end
    end
  end
end
