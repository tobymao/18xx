# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../skip_coal_and_oil'

module Engine
  module Game
    module G1868WY
      module Step
        class DoubleHeadTrains < Engine::Step::Base
          include SkipCoalAndOil

          ACTIONS = %w[double_head_trains pass].freeze

          def setup
            @game.double_headed_trains = []
          end

          def description
            'Double-Head Trains'
          end

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.corporation?
            return [] unless @game.double_head_candidates(entity).size > 1
            return [] unless @game.can_run_route?(entity)

            ACTIONS
          end

          def process_double_head_trains(action)
            trains = action.trains
            corporation = action.entity

            raise GameError 'Cannot double head with fewer than 2 trains' if trains.size < 2

            train = get_double_headed_train!(trains)

            train.owner = corporation
            corporation.trains << train

            @log << "#{corporation.name} forms #{an(train.distance[1]['pay'])} "\
                    "#{train.name} train by double heading trains: #{trains.map(&:name).sort.join(', ')}"
          end

          def an(number)
            case number
            when 8, 11, 18
              'an'
            else
              'a'
            end
          end

          def get_double_headed_train!(trains)
            @game.double_headed_trains.concat(trains)
            valid_trains = @game.double_head_candidates(trains.first.owner)

            trains.each do |train|
              raise GameError "Cannot double head train #{train.id}" unless valid_trains.include?(train)

              # prevent given trains from running individually this OR
              train.operated = true
            end

            # double-headed train's ID is formed by combining the the IDs of the
            # given trains, so that if they are double headed this way again,
            # the double headed train does not need to be recreated, and the
            # route auto-selector can use its previous route
            sym = trains.map(&:id).sort.join('_')

            # temporarily detach big boy token from individual train that is
            # being double-headed
            if (big_boy_train = trains.find { |t| t == @game.big_boy_train })
              @game.detach_big_boy
              @game.big_boy_train_dh_original = big_boy_train
            end

            if (train = @game.train_by_id("#{sym}-0"))
              # refresh double-headed train that ran previously
              train.operated = false
              train.rusted = false
            else
              distance, name = combined_distance_and_name(trains)

              train = Engine::Train.new(
                name: sym,
                distance: distance,
                price: 0,
              )

              # simplify name to C+t form, after id is set via sym
              train.name = name

              # make train available to @game.train_by_id, but don't keep in
              # Depot
              @game.depot.add_train(train)
              @game.update_trains_cache
              @game.remove_train(train)
            end

            # temporarily attach big boy token to the double-headed train
            @game.attach_big_boy(train, log: false, double_head: true) if big_boy_train

            # run train this OR, then remove it from company automatically via
            # base logic for obsolete trains
            train.obsolete = true

            train
          end

          def combined_distance_and_name(trains)
            cities, towns = trains.each_with_object([0, 0]) do |train, c_t|
              c, t = @game.distance(train)
              c_t[0] += c
              c_t[1] += t
            end

            distance = [
              { 'nodes' => ['town'], 'pay' => towns, 'visit' => towns },
              { 'nodes' => %w[city offboard town], 'pay' => cities, 'visit' => cities },
            ]
            name = "#{cities}+#{towns}"

            [distance, name]
          end
        end
      end
    end
  end
end
