# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'tiles'
require_relative '../g_1858/game'

module Engine
  module Game
    module G1858India
      class Game < G1858::Game
        include_meta(G1858India::Meta)
        include Entities
        include Map
        include Tiles

        CURRENCY_FORMAT_STR = '£%s'
        BANK_CASH = 16_000
        STARTING_CASH = { 3 => 665, 4 => 500, 5 => 400, 6 => 335 }.freeze
        CERT_LIMIT = { 3 => 27, 4 => 20, 5 => 16, 6 => 13 }.freeze

        TRAIN_COUNTS = {
          '2H' => 8,
          '4H' => 7,
          '6H' => 5,
          '5E' => 4,
          '6E' => 3,
          '7E' => 20,
          '5D' => 10,
          'Mail' => 4,
        }.freeze

        PHASE4_TRAINS_RUST = 7 # 6H/3M trains rust after the seventh grey train is bought.

        def operating_round(round_num = 1)
          @round_num = round_num
          Engine::Round::Operating.new(self, [
            G1858India::Step::Track,
            G1858::Step::Token,
            G1858India::Step::Route,
            G1858::Step::Dividend,
            G1858::Step::DiscardTrain,
            G1858India::Step::BuyTrain,
            G1858::Step::IssueShares,
          ], round_num: round_num)
        end

        def game_trains
          unless @game_trains
            @game_trains = super.map(&:dup)
            # Add the 1M variant to the 2H train.
            @game_trains.first['variants'] =
              [
                {
                  name: '1M',
                  no_local: true,
                  distance: [{ 'nodes' => %w[city offboard], 'pay' => 1, 'visit' => 1 },
                             { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 }],
                  track_type: :narrow,
                  price: 70,
                },
              ]
            @game_trains <<
              {
                name: 'Mail',
                distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                           { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 }],
                track_type: :broad,
                price: 100,
                available_on: '3',
              }
          end
          @game_trains
        end

        def num_trains(train)
          TRAIN_COUNTS[train[:name]]
        end

        def mail_train?(train)
          train.name == 'Mail'
        end

        def owns_mail_train?(corporation)
          corporation.trains.any? { |train| mail_train?(train) }
        end

        def must_buy_train?(corporation)
          # A mail train doesn't fulfil the requirement to own a train.
          corporation.trains.none? { |train| !mail_train?(train) }
        end

        def num_corp_trains(corporation)
          # Mail trains don't count towards train limit.
          corporation.trains.count { |train| !mail_train?(train) }
        end

        def route_trains(entity)
          # Don't show mail trains in the route selector.
          entity.runnable_trains.reject { |train| mail_train?(train) }
        end

        def revenue_for(route, stops)
          super + mail_bonus(route, stops)
        end

        def game_phases
          unless @game_phases
            @game_phases = super.map(&:dup)
            @game_phases.first[:status] = %w[yellow_privates narrow_gauge]
          end
          @game_phases
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          super || gauge_conversion?(from, to)
        end

        # Checks whether a tile can replace another as a gauge conversion.
        # To do this it must:
        #   - Be the same colour as the previous one (yellow or green).
        #   - Have the same cities and towns as the previous one.
        #   - Have the same number of exits as the previous one.
        #   - Have the same arrangement of track as the previous one.
        #   - Have either:
        #     - one section of track connecting two edges changed from broad
        #       gauge to narrow gauge or vice versa, or
        #     - two sections of track connecting a town or city to edges changed
        #       from broad gauge to narrow gauge.
        # The check for the number of track sections changes is done in
        # G1858India::Step::Track.old_paths_maintained?
        def gauge_conversion?(from, to)
          return false unless from.color == to.color
          return false unless upgrades_to_correct_label?(from, to)
          return false unless from.cities.size == to.cities.size
          return false unless from.towns.size == to.towns.size
          return false unless from.paths.size == to.paths.size

          Engine::Tile::ALL_EDGES.any? do |ticks|
            from.paths.all? do |p|
              path = p.rotate(ticks)
              to.paths.any? do |other|
                path.ends.all? { |pe| other.ends.any? { |oe| pe <= oe } }
              end
            end
          end
        end

        private

        def mail_bonus(route, stops)
          train = route.train
          return 0 unless @round.mail_trains[train.owner] == train

          10 * stops.count { |stop| stop.city? || stop.offboard? }
        end
      end
    end
  end
end
