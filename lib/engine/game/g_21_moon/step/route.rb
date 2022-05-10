# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G21Moon
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? || entity.runnable_trains.empty? || !@game.can_run_route?(entity)

            actions = %w[run_routes]
            actions << 'choose' if can_move?(entity) && !entity.receivership?
            actions
          end

          def setup
            super
            @moved = nil
          end

          def can_move?(entity)
            !entity.trains.empty? && entity.trains.size < 4 && !@moved
          end

          def train_name(_entity, train)
            @game.train_name(train)
          end

          def process_choose(action)
            corp = action.entity
            train = corp.trains[action.choice.to_i]
            raise GameError, 'Invalid choice for train' unless train

            base = @game.train_base[train]

            raise GameError, 'No room to move train' if base == :sp && @game.lb_trains(corp).size > 1
            raise GameError, 'No room to move train' if base == :lb && @game.sp_trains(corp).size > 1

            new_base = (base == :sp ? :lb : :sp)

            @log << "#{corp.name} transfers #{@game.train_name(train)} to #{new_base.to_s.upcase}"
            @game.assign_base(train, new_base)

            @moved = true
          end

          def choice_name
            'Optional Transfer (once per turn)'
          end

          def choices
            choice_list = []
            corp = current_entity
            if @game.sp_trains(corp).size < 2
              @game.lb_trains(corp).uniq(&:name).each do |t|
                choice_list << [corp.trains.index(t).to_s, "Transfer #{t.name} to SP"]
              end
            end
            if @game.lb_trains(corp).size < 2
              @game.sp_trains(corp).uniq(&:name).each do |t|
                choice_list << [corp.trains.index(t).to_s, "Transfer #{t.name} to LB"]
              end
            end
            choice_list.to_h
          end

          def process_run_routes(action)
            super
            @game.update_end_bonuses(action.entity, action.routes)
          end

          def available_hex(entity, hex)
            @game.graph.reachable_hexes(entity)[hex]
          end
        end
      end
    end
  end
end
