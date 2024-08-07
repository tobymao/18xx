# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1826
      class Game < Game::Base
        attr_reader :recently_floated, :can_buy_trains

        include_meta(G1826::Meta)
        include Entities
        include Map

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        lightishBlue: '#0097df',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037',
                        violet: '#601d39',
                        sand: '#c89432')
        TRACK_RESTRICTION = :semi_restrictive
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        HOME_TOKEN_TIMING = :float
        CURRENCY_FORMAT_STR = 'F%s'
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        CAPITALIZATION = :incremental
        MUST_BUY_TRAIN = :always

        BANK_CASH = 12_000

        CERT_LIMIT = { 2 => 28, 3 => 20, 4 => 16, 5 => 13, 6 => 11 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450, 5 => 360, 6 => 300 }.freeze

        MERGER_CORPS = %w[Etat SNCF].freeze

        MARKET = [
          %w[82 90 100 110p 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 82 90 100p 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90p 100 110 122 135 150 165 180],
          %w[65 70 75 82p 90 100 110 122],
          %w[60y 65 70 75p 82 90],
          %w[50y 60y 65 70 75],
          %w[40y 50y 60y 65],
        ].freeze

        PHASES = [{ name: '2H', train_limit: { five_share: 2, ten_share: 4 }, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '4H',
                    on: '4H',
                    train_limit: { five_share: 2, ten_share: 4 },
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '6H',
                    on: '6H',
                    train_limit: { five_share: 1, ten_share: 3 },
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '10H',
                    on: '10H',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: 'E',
                    on: 'E',
                    train_limit: 2,
                    tiles: %i[yellow green brown blue],
                    operating_rounds: 3,
                  },
                  {
                    name: 'TVG',
                    on: 'TVG',
                    train_limit: 2,
                    tiles: %i[yellow green brown blue gray],
                    operating_rounds: 3,
                  }].freeze

        TRAINS = [
                    { name: '2H', distance: 2, price: 100, rusts_on: '6H', num: 8 },
                    { name: '4H', distance: 4, price: 200, rusts_on: '10H', num: 7 },
                    {
                      name: '6H',
                      distance: 6,
                      price: 300,
                      rusts_on: 'E',
                      num: 6,
                      events: [{ 'type' => 'can_buy_trains' }],
                    },
                    {
                      name: '10H',
                      distance: 10,
                      price: 600,
                      num: 5,
                      events: [{ 'type' => 'close_companies' }],
                    },
                    {
                      name: 'E',
                      # distance is equal to the number of E and TGV trains in play. The run is doubled until a TVG is purchased.
                      distance: [{ 'nodes' => %w[city offboard], 'pay' => 99, 'visit' => 99, 'multiplier' => 2 },
                                 { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                      price: 800,
                      num: 2,
                      events: [{ 'type' => 'remove_abilities' }],
                    },
                    {
                      name: 'TGV',
                      distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 99, 'multiplier' => 2 },
                                 { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                      price: 1000,
                      num: 20,
                      discount: { '4' => 300, '5' => 300, '6' => 300 },
                    },
                  ].freeze

        ASSIGNMENT_TOKENS = {
          'P2' => '/icons/1826/mail.svg',
        }.freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_abilities' => ['Mail Token Removed'],
          'can_buy_trains' => ['Corporations can buy trains from other corporations'],
        ).freeze

        # Corps may lay two yellow tiles on their first OR
        def tile_lays(entity)
          lays = [{ lay: true, upgrade: true }]
          lays << { lay: :not_if_upgraded, upgrade: false } if @recently_floated&.include?(entity)
          lays
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
            G1826::Step::Token,
            Engine::Step::Route,
            G1826::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1826::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def setup
          @can_buy_trains = false
          @recently_floated = []
        end

        def or_round_finished
          @recently_floated = []
        end

        def float_corporation(corporation)
          @recently_floated << corporation unless merger_corp?(corporation)

          super
        end

        def merger_corp(corporation)
          MERGER_CORPS.include?(corporation.id)
        end

        def regie
          @regie ||= company_by_id('P2')
        end

        # minimum bid increment in the auction
        def min_increment
          5
        end

        def revenue_for(route, stops)
          revenue = super

          revenue += 10 if route.corporation.assigned?(regie.id) && stops.find { |s| s.hex.assigned?(regie.id) }
          raise GameError, 'Route visits same hex twice' if route.hexes.size != route.hexes.uniq.size

          # Add code here for TGV train bonuses
          revenue
        end

        def event_remove_abilities!
          @log << 'Company abilities are removed'
          removals = Hash.new { |h, k| h[k] = {} }

          @corporations.each do |corp|
            corp.assignments.dup.each do |company, _|
              removals[company][:corporation] = corp.name
              corp.remove_assignment!(company)
            end
          end

          @hexes.each do |hex|
            hex.assignments.dup.each do |company, _|
              removals[company][:hex] = hex.name
              hex.remove_assignment!(company)
            end
          end

          removals.each do |company, removal|
            corp = removal[:corporation]
            @log << "-- Event: #{corp}'s #{company_by_id(company).name} ability is removed --"
          end
        end

        def event_can_buy_trains!
          @can_buy_trains = true
          @log << 'Corporations can buy trains from other corporations'
        end
      end
    end
  end
end
