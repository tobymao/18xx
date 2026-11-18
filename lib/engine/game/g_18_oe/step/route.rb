# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18OE
      module Step
        class Route < Engine::Step::Route
          ORIENT_EXPRESS_HELP = '2+2, 3 and 4 trains may be combined into one train to make an Orient Express run. '\
                                'A combined train must run an Orient Express route; use Undo to cancel a combination.'
          SEA_HELP = 'Click a city or town across the sea to add a crossing; each sea zone and ferry distance counts '\
                     "against the train's city limit, less 1 per port token on the route (2 from Phase 7)."
          POOL_HELP = " Port authorities and Minor H reduce the railroad's total, shared by its trains; "\
                      'the trains earning most use it first.'

          def actions(entity)
            return [] if @game.repeat_last_revenue?(entity)

            actions = super
            return actions if actions.empty?

            actions += %w[double_head_trains] if combining_offered?(entity)
            actions += %w[choose] unless pullman_train_choices(entity).empty?
            actions
          end

          def combining_offered?(entity)
            return false if @game.double_head_candidates(entity).size < 2

            @game.loading || @game.orient_express_reachable?(entity)
          end

          def choice_name
            'Attach the Pullman to a train'
          end

          def choices
            pullman_train_choices(current_entity).to_h { |train| [train.id, "#{train.name} train"] }
          end

          def pullman_train_choices(entity)
            return [] unless @game.pullman(entity)

            @game.route_trains(entity).reject { |train| train.operated || train == @round.pullman_train }
          end

          def process_choose(action)
            entity = action.entity
            train = pullman_train_choices(entity).find { |t| t.id == action.choice }
            raise GameError, 'Cannot attach the Pullman to that train' unless train

            @round.pullman_train = train
            @log << "#{entity.name} attaches the Pullman to the #{train.name} train"
          end

          def train_name(_corporation, train)
            @round.pullman_train == train ? "#{train.name} + Pullman" : train.name
          end

          def log_skip(entity)
            super unless @game.repeat_last_revenue?(entity)
          end

          def help
            base_help = super
            extra = []
            extra << ORIENT_EXPRESS_HELP if current_entity.type == :major && @game.non_permanent_trains?
            extra << sea_help if @game.sea_connectivityable?(current_entity)
            return base_help if extra.empty?

            Array(base_help).reject(&:empty?) + extra
          end

          def sea_help
            pool = !@game.port_authorities(current_entity).empty? || @game.minor_h_reduction?(current_entity)
            pool ? SEA_HELP + POOL_HELP : SEA_HELP
          end

          def round_state
            super.merge(combined_trains: {}, orient_express_revenue: nil, pullman_train: nil)
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
            @round.pullman_train = nil
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
            @round.pullman_train = train if trains.include?(@round.pullman_train)

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
              level = trains.map(&:level).max
              train = G18OE::Train.new(name: sym, distance: distance, price: 0, level: level)
              train.name = "#{cities}+#{towns}C"

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
