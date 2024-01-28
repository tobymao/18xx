# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G18Uruguay
      module Step
        class Track < Engine::Step::Track
          def actions(entity)
            return [] if entity == @game.rptla
            return [] if @game.final_operating_round?

            @round.loan_taken |= false
            actions = super.map(&:clone)
            actions << 'take_loan' if @game.can_take_loan?(entity) && !@round.loan_taken && !@game.nationalized?
            actions
          end

          def destination_node_check?(entity)
            return if entity.destination_coordinates.nil?

            destination_hex = @game.hex_by_id(entity.destination_coordinates)
            home_node = entity.tokens.first.city
            destination_hex.tile.nodes.first&.walk(corporation: entity) do |path, _, _|
              return true if path.nodes.include?(home_node)
            end
            false
          end

          def check_and_apply_destination_bonus
            corporation = current_entity.corporation
            apply_destination_bonus(corporation) if destination_node_check?(corporation)
          end

          def apply_destination_bonus(corporation)
            ability = @game.abilities(corporation, :destination_bonus)
            @game.second_capitalization!(corporation) unless ability.nil?
            ability&.use!
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            ret = super
            check_and_apply_destination_bonus
            ret
          end

          def pass!
            check_and_apply_destination_bonus
            super
          end

          def process_take_loan(action)
            entity = action.entity
            @game.take_loan(entity, action.loan) unless @round.loan_taken
            @round.loan_taken = true
          end
        end
      end
    end
  end
end
