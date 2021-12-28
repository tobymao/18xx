# frozen_string_literal: true

require_relative '../../../game_error'
require_relative '../../../step/route'

module Engine
  module Game
    module G18SJ
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] unless can_run_trains?(actual_entity(entity))

            ACTIONS
          end

          def available_hex(entity, hex)
            @game.graph.reachable_hexes(actual_entity(entity))[hex]
          end

          GKB_BONUS = { 3 => 50, 2 => 30, 1 => 20 }.freeze

          def process_run_routes(action)
            route = action.routes.first
            abilities = route&.abilities
            ability_type = abilities.first if abilities
            used_ability = @game.abilities(action.entity, ability_type) if ability_type
            count = used_ability&.count

            super

            return unless count

            if count == 1
              @game.log << "All OR bonuses for #{@game.gkb.name} used up"
            else
              current_amount = GKB_BONUS[count]
              next_amount = GKB_BONUS[count - 1]
              @game.log << "#{@game.gkb.name} bonus decrease from #{@game.format_currency(current_amount)} to "\
                           "#{@game.format_currency(next_amount)}"
              used_ability.amount = next_amount
            end
          end

          def chart(_entity)
            [
              %w[Name Bonus],
              ['Lapplandspilen (N-S)', @game.format_currency(100)],
              ['Öst-Väst (Ö-V)', @game.format_currency(120)],
              ['Malmfälten 1 (M-m)', @game.format_currency(50)],
              ['Malmfälten 2 (M-m-m)', @game.format_currency(100)],
              ['Bergslagen 1 (B-b)', @game.format_currency(50)],
              ['Bergslagen 2 (B-b-b)', @game.format_currency(100)],
            ]
          end

          private

          def can_run_trains?(entity)
            entity.operator? && !entity.runnable_trains.empty? && @game.can_run_route?(entity)
          end

          def bonus_available?(entity)
            return false unless entity.company?
            return false if !@game.gkb ||
              @game.gkb.closed? ||
              entity.player != gkb_owner&.player ||
              !current_entity.corporation? ||
              current_entity != @gkb_owner

            @game.abilities(@game.gkb, :hex_bonus, time: 'route')
          end

          def gkb_owner
            @gkb_owner ||= @game.gkb&.owner
          end

          def actual_entity(entity)
            bonus_available?(entity) ? entity.owner : entity
          end
        end
      end
    end
  end
end
