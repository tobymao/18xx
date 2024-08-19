# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Norway
      module Step
        class BuildTunnel < Engine::Step::Base
          def description
            'Build tunnel'
          end

          def actions(entity)
            actions = []
            actions << 'choose' if !mountain_hex.nil? && @game.mountain?(mountain_hex) && can_build_tunnel?(entity, mountain_hex)
            actions
          end

          def choosing?(_entity)
            true
          end

          def mountain_hex
            @round.mountain_hex
          end

          def build_cost(_hex)
            return 0 if current_entity.abilities.any? { |a| a.type == :free_tunnel }
            return 0 unless @game.mountain?(mountain_hex)

            @game.small_mountain?(mountain_hex) ? 30 : 40
          end

          def can_build_tunnel?(entity, hex)
            entity.corporation? && entity.cash >= build_cost(hex)
          end

          def choice_name
            'Build tunnel'
          end

          def choices
            cost = build_cost(mountain_hex)
            { 'pass' => 'Pass', 'build' => "Build tunnel #{@game.format_currency(cost)}" }
          end

          def build_tunnel(entity, cost)
            @log << "#{entity.name} pays #{@game.format_currency(cost)} to build tunnel at #{mountain_hex.id}"
            entity.spend(cost, @game.bank) if cost.positive?

            factory_owner = @game.company_by_id('P3').owner
            @game.bank.spend(10, factory_owner) if factory_owner
            @log << "#{factory_owner.name} receives #{@game.format_currency(10)} for building a tunnel" if factory_owner

            mountain = mountain_hex.assignments.keys.find { |a| a.include? 'MOUNTAIN' }
            mountain_hex.remove_assignment!(mountain)
          end

          def process_choose(action)
            @round.mountain_hex = nil if action.choice == 'pass'
            return if action.choice == 'pass'

            cost = build_cost(@round.mountain_hex)
            raise GameError, "Cannot afford #{cost} to build a tunnel" if action.entity.cash < cost

            build_tunnel(action.entity, cost)
            @round.mountain_hex = nil
          end
        end
      end
    end
  end
end
