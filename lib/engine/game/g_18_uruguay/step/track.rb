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

          def check_and_apply_destination_bonus
            corporation = current_entity.corporation
            graph = @game.graph_for_entity(corporation)
            nodes = graph.connected_nodes(corporation).keys
            apply_destination_bonus(corporation) if nodes.find { |node| node.hex.id == corporation.destination_coordinates }
          end

          def apply_destination_bonus(corporation)
            ability = @game.abilities(corporation, :destination_bonus)
            @game.second_capitilization!(corporation) unless ability.nil?
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
