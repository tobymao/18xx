# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18SJ
      module Step
        class AssignGotaKanalbolaget < Engine::Step::Assign
          ACTIONS = %w[assign].freeze

          def actions(entity)
            if @round.current_operator == @game.gkb.owner &&
                (ability = ability(@round.current_operator))
              return ACTIONS 
            end

            []
          end

          def description
            'Assign a Göta kanal token to a hex'
          end

          def ability(entity)
            return if !@game.gkb || @game.gkb.owner != entity

            ability = @game.abilities(entity, :assign_hexes)
            return if !ability || ability.count == 0

            ability
          end

          def process_assign(action)
            entity = action.entity
            ability = ability(entity)
            target = action.target

            assignable_hexes = ability.hexes.map { |h| @game.hex_by_id(h) }
            assign_gkb_bonus(target, ability)

            return unless ability.count == 1

            last_target = @game.gkb_hexes.find { |h| !@game.gkb_hex_assigned?(h) }
            assign_gkb_bonus(last_target, ability)
          end

          def blocks?
            @game.gkb&.owner && @round.current_operator == @game.gkb.owner && ability(@round.current_operator)
          end

          def available_hex(entity, hex)
            return unless @game.gkb_hexes.include?(hex)
            return if @game.gkb_hex_assigned?(hex)
    
            @game.hex_by_id(hex.id).neighbors.keys
          end

          def assign_gkb_bonus(target, ability)
            id = "GKB#{amount(ability)}"
            target.assign!(id)
            amount_str = @game.format_currency(amount(ability))
            ability.use!
            @game.log << "Assigned a Göta kanal #{amount_str} token to hex #{target.name} using icon #{id}"
          end

          def amount(ability)
            ability.count == 3 ? 50 : 30
          end
        end
      end
    end
  end
end
