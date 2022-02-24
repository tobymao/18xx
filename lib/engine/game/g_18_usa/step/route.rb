# frozen_string_literal: true

require_relative '../../../step/route'
module Engine
  module Game
    module G18USA
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? || @game.route_trains(entity).empty? || !@game.can_run_route?(entity)

            @upgrade_train_assignments ||= {}
            actions = ACTIONS.dup
            actions << 'choose' unless choices_for_entity(entity).empty?
            actions
          end

          def round_state
            super.merge({
                          train_upgrade_assignments: {},
                        })
          end

          def attach_upgrade(train, upgrade)
            @upgrade_train_assignments[upgrade] = train
            @round.train_upgrade_assignments[train] = [] unless @round.train_upgrade_assignments[train]
            @round.train_upgrade_assignments[train] << upgrade
            train.name = train.name + (upgrade[:size] ? "#{upgrade[:id]}#{upgrade[:size]}" : upgrade[:id])
            train.distance = train.distance + upgrade[:size] if upgrade[:size]
          end

          def available_hex(entity, hex)
            return super if @game.company_by_id('P19').closed? || @game.company_by_id('P19').owner != entity

            # This corporation owns the jumper; we need to be able to jump over tokens
            @game.jump_graph.connected_hexes(entity)[hex]
          end

          def choice_name
            'Attach an upgrade to a train?'
          end

          def choices
            choices_for_entity(current_entity)
          end

          def choices_for_entity(entity)
            choices = {}
            upgrade_choices(entity).each_with_index do |upgrade, p_index|
              train_choices(entity, upgrade[:permanents]).each_with_index do |train, t_index|
                choices["#{t_index}-#{p_index}"] = "Attach #{upgrade[:name]} upgrade to #{train.name} train"
              end
            end
            choices
          end

          def detach_upgrades
            @upgrade_train_assignments.each do |upgrade, train|
              train.name = train.name.gsub(upgrade[:size] ? "#{upgrade[:id]}#{upgrade[:size]}" : upgrade[:id], '')
              train.distance = train.distance - upgrade[:size] if upgrade[:size]
            end
            @upgrade_train_assignments = {}
            @round.train_upgrade_assignments = {}
          end

          def train_choices(entity, allow_permanents)
            # Pullmans don't get upgrades. That'd be silly.
            @game.route_trains(entity).reject do |t|
              (!allow_permanents && !t.obsolete_on && !t.rusts_on) || @game.pullman_train?(t)
            end
          end

          def upgrade_choices(entity)
            choices = []
            choices << { name: 'Switcher', id: '/', size: 1, permanents: true } if !@game.company_by_id('P19').closed? &&
              @game.company_by_id('P19').owner == entity
            choices << { name: 'Extender', id: '+', size: 1, permanents: false } if !@game.company_by_id('P30').closed? &&
              @game.company_by_id('P30').owner == entity
            choices << { name: 'Pullman', id: 'P', size: nil, permanents: true } if entity.trains.any? do |t|
                                                                                      @game.pullman_train?(t)
                                                                                    end
            choices.reject { |upgrade| @upgrade_train_assignments[upgrade] }
          end

          def process_choose(action)
            entity = action.entity
            choices = action.choice.split('-', -1).map(&:to_i)
            upgrade = upgrade_choices(entity)[choices[1]]
            train = train_choices(entity, upgrade[:permanents])[choices[0]]
            @log << "#{entity.id} chooses to attach the #{upgrade[:name]} upgrade to the #{train.name} train"
            attach_upgrade(train, upgrade)
          end

          def process_run_routes(action)
            super

            detach_upgrades unless @upgrade_train_assignments.empty?
          end
        end
      end
    end
  end
end
