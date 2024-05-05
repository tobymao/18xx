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
            hex = @round.mountain_hex
            actions = []
            actions << 'choose' if !hex.nil? && @game.mountain?(hex) && can_build_tunnel?(entity, hex)
            actions
          end

          def choosing?(_entity)
            true
          end

          def build_cost(_hex)
            return 0 if current_entity.abilities.any? { |a| a.type == :free_tunnel }
            
            @game.small_mountain?(@round.mountain_hex) ? 30 : 40
          end

          def can_build_tunnel?(entity, hex)
            entity.corporation? && entity.cash >= build_cost(hex)
          end

          def choice_name
            'Build tunnel'
          end

          def choices
            cost = build_cost(@round.mountain_hex)
            { 'pass' => 'Pass', 'build' => "Build tunnel #{@game.format_currency(cost)}" }
          end

          def build_tunnel(entity, cost)
            hex = @round.mountain_hex

            @log << "#{entity.name} pays #{@game.format_currency(cost)} to build tunnel at #{hex.id}"
            entity.spend(cost, @game.bank) if cost.positive?

            factory_owner = @game.company_by_id('P3').owner
            @game.bank.spend(10, factory_owner)
            @log << "#{factory_owner.name} receives #{@game.format_currency(10)} for building a tunnel"

            mountain = hex.assignments.keys.find { |a| a.include? 'MOUNTAIN' }
            hex.remove_assignment!(mountain)
          end

          def process_choose(action)
            cost = 0
            cost = build_cost(@round.mountain_hex) unless action.choice == 'pass'
            raise GameError, "Cannot afford #{cost} to build a tunnel" if action.entity.cash < cost

            build_tunnel(action.entity, cost) unless action.choice == 'pass'
            pass!
          end
        end
      end
    end
  end
end
