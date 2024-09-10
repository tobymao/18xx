# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'tiles'
require_relative '../g_1858/game'

module Engine
  module Game
    module G1858Switzerland
      class Game < G1858::Game
        include_meta(G1858Switzerland::Meta)
        include Entities
        include Map
        include Tiles

        CURRENCY_FORMAT_STR = '%ssfr'

        BANK_CASH = 8_000
        STARTING_CASH = { 2 => 500, 3 => 335, 4 => 250 }.freeze
        CERT_LIMIT = { 2 => 20, 3 => 13, 4 => 10 }.freeze

        PHASES = G1858::Trains::PHASES.reject { |phase| phase[:name] == '7' }
        STATUS_TEXT = G1858::Trains::STATUS_TEXT.merge(
          'green_privates' => [
            'Yellow and green privates available',
            'The first and second batches of private companies can be auctioned',
          ],
          'all_privates' => [
            'All privates available',
            'The first, second and third batches of private companies can be auctioned',
          ],
          'blue_privates' => [
            'Blue privates available',
            'The third batch of private companies can be auctioned',
          ],
        ).freeze
        EVENTS_TEXT = G1858::Trains::EVENTS_TEXT.merge(
          'blue_privates_available' => [
            'Blue privates can start',
            'The third set of private companies becomes available',
          ],
          'privates_close' => [
            'Yellow/green private companies close',
            'The first private closure round takes place at the end of the ' \
            'operating round in which the first 5E/4M train is bought',
          ],
          'privates_close2' => [
            'Blue private companies close',
            'The second private closure round takes place at the end of the ' \
            'operating round in which the first 6E/5M train is bought',
          ],
        ).freeze

        def game_phases
          phases = super
          _phase2, _phase3, phase4, phase5, phase6 = phases
          phase4[:status] = %w[all_privates narrow_gauge]
          phase5[:status] = %w[blue_privates public_companies dual_gauge]
          phase6[:tiles] = %i[yellow green brown gray]
          phases
        end

        def timeline
          @timeline = ['5D trains are available after the first 6E/5M train has been bought.',
                       '4H/2M trains rust when the second 6E/5M/5D train is bought.',
                       '6H/3M trains are wounded when the second 6E/5M/5D train is bought.',
                       '6H/3M trains rust when the fourth 6E/5M/5D train is bought.']
        end

        def event_blue_privates_available!
          @log << '-- Event: Blue private companies can be started --'
          # Don't need to change anything, the check in buyable_bank_owned_companies
          # will let these companies be auctioned in future stock rounds.
        end

        def event_privates_close!
          @log << '-- Event: Yellow and green private companies will close ' \
                  'at the end of this operating round --'
          @private_closure_round = :next
        end

        def event_privates_close2!
          @log << '-- Event: Blue private companies will close at the end ' \
                  'of this operating round --'
          @private_closure_round = :next
        end

        TRAINS = G1858::Trains::TRAINS.reject { |train| train[:name] == '7E' }
        TRAIN_COUNTS = {
          '2H' => 4,
          '4H' => 3,
          '6H' => 3,
          '5E' => 2,
          '6E' => 10,
          '5D' => 5,
        }.freeze
        GREY_TRAINS = %w[6E 5M 5D].freeze

        def game_trains
          trains = super
          _train_2h, _train_4h, train_6h, _train_5e, train_6e, train_5d = trains
          train_6h.delete(:obsolete_on) # Wounded on second grey train, handled in code
          train_6h[:events] = [{ 'type' => 'blue_privates_available' }]
          train_6e[:events] = [{ 'type' => 'privates_close2' }]
          train_6e[:price] = 700
          train_6e[:variants][0][:price] = 600
          train_5d[:available_on] = '6'
          trains
        end

        def num_trains(train)
          TRAIN_COUNTS[train[:name]]
        end

        PHASE4_TRAINS_OBSOLETE = 2 # 6H/3M trains wounded after second grey train is bought.
        PHASE3_TRAINS_RUST = 2 # 4H/2M trains rust after second grey train is bought.
        PHASE4_TRAINS_RUST = 4 # 6H/3M trains rust after fourth grey train is bought.

        def setup
          super
          @phase4_train_trigger = PHASE4_TRAINS_RUST
        end
      end
    end
  end
end
