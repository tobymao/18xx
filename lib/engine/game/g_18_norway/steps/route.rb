# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18Norway
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? || @game.route_trains(entity).empty? || !@game.can_run_route?(entity)

            @upgrade_train_assignments ||= {}
            actions = ACTIONS.dup
            actions << 'choose' if @game.switcher?(entity)
            actions
          end

          def available_hex(entity, hex)
            return true if super(entity, hex)
            return true if @game.ferry_graph.reachable_hexes(entity)[hex]

            return @game.jump_graph.connected_hexes(entity)[hex] if @game.switcher?(entity)

            false
          end

          def choice_name
            'Attach an upgrade to a train?'
          end

          def choices
            choices_for_entity(current_entity)
          end

          def choices_for_entity(entity)
            return {} if @upgrade_train_assignments[:Switcher]

            choices = {}
            @game.route_trains(entity).each_with_index do |train, t_index|
              choices[t_index.to_s] = "Attach Switcher upgrade to #{train.name} train"
            end
            choices
          end

          def round_state
            super.merge({
                          train_upgrade_assignments: {},
                        })
          end

          def attach_upgrade(train)
            upgrade = :Switcher
            @upgrade_train_assignments[upgrade] = train
            @round.train_upgrade_assignments[train] = [] unless @round.train_upgrade_assignments[train]
            @round.train_upgrade_assignments[train] << upgrade
            train.name = train.name + '/1'
            train.distance = train.distance + 1
          end

          def detach_upgrades
            @upgrade_train_assignments.each do |_upgrade, train|
              train.name = train.name.gsub('/1', '')
              train.distance = train.distance - 1
            end
            @upgrade_train_assignments = {}
            @round.train_upgrade_assignments = {}
          end

          def process_choose(action)
            train = @game.route_trains(action.entity)[action.choice.to_i]
            attach_upgrade(train)
          end

          def process_run_routes(action)
            fee = action.routes.reduce(0) { |_num, route| @game.route_cost(route) }
            action.entity.spend(fee, @game.bank) if fee.positive?
            @log << "#{action.entity.name} spends #{@game.format_currency(fee)} on fees" if fee.positive?
            super

            detach_upgrades unless @upgrade_train_assignments.empty?
          end
        end
      end
    end
  end
end
