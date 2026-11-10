# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18OE
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if @game.repeat_last_revenue?(entity)

            actions = super
            return actions if actions.empty? || @game.double_head_candidates(entity).size < 2
            return actions if !@game.loading && !@game.orient_express_reachable?(entity)

            actions + %w[double_head_trains]
          end

          def log_skip(entity)
            super unless @game.repeat_last_revenue?(entity)
          end

          def help
            base_help = super
            return base_help if current_entity.type != :major || !@game.non_permanent_trains?

            Array(base_help).reject(&:empty?) + [
              '2+2, 3 and 4 trains may be combined into one train to make an Orient Express run. '\
              'A combined train must run an Orient Express route; use Undo to cancel a combination.',
            ]
          end

          def round_state
            super.merge(combined_trains: {}, orient_express_revenue: nil)
          end

          def double_head_trains_title
            'Combine trains'
          end

          def double_head_trains_description
            'Combine two or more non-permanent trains (levels 2, 3 and 4) into one train to make an Orient Express run. '\
              'A combined train must run an Orient Express route. Use Undo to cancel a combination.'
          end

          def setup
            super
            @round.combined_trains = {}
            @round.orient_express_revenue = nil
          end

          def process_run_routes(action)
            super
            @round.orient_express_revenue = @game.orient_express_train_revenue(@round.routes)
            remove_combined_trains!
          end

          def process_double_head_trains(action)
            corporation = action.entity
            trains = action.trains
            candidates = @game.double_head_candidates(corporation)

            raise GameError, 'Cannot combine fewer than 2 trains' if trains.size < 2
            raise GameError, 'Cannot combine the same train twice' if trains.uniq.size != trains.size

            trains.each do |train|
              raise GameError, "Cannot combine train #{train.id}" unless candidates.include?(train)
            end

            trains.each { |train| train.operated = true }

            train = combined_train!(trains)
            train.owner = corporation
            corporation.trains << train
            @round.combined_trains[train] = trains

            @log << "#{corporation.name} combines #{trains.map(&:name).sort.join(', ')} into "\
                    "#{an(train.distance[1]['pay'])} #{train.name} train for the Orient Express"
          end

          def an(number)
            case number
            when 8, 11, 18
              'an'
            else
              'a'
            end
          end

          private

          def remove_combined_trains!
            @round.combined_trains.each_key do |train|
              @game.remove_train(train)
              train.owner = nil
            end
          end

          def combined_train!(trains)
            sym = trains.map(&:id).sort.join('_')

            if (train = @game.train_by_id("#{sym}-0"))
              train.operated = false
              train.rusted = false
            else
              cities, towns = trains.map { |component| @game.distance(component) }.transpose.map(&:sum)
              distance = [
                { 'nodes' => ['town'], 'pay' => towns, 'visit' => 99 },
                { 'nodes' => %w[city offboard town], 'pay' => cities, 'visit' => cities },
              ]
              train = Engine::Train.new(name: sym, distance: distance, price: 0)
              train.name = "#{cities}+#{towns}"

              @game.depot.add_train(train)
              @game.update_trains_cache
              @game.remove_train(train)
            end

            train.reserved = true
            train
          end
        end
      end
    end
  end
end
