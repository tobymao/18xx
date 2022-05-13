# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G18SJ
      module Step
        class AssignGotaKanalbolaget < Engine::Step::Assign
          ACTIONS = %w[assign].freeze

          def actions(entity)
            return ACTIONS if ability(entity)

            []
          end

          def description
            'Assign a Göta kanal token to a hex'
          end

          def ability(entity)
            return if !entity || !@game.gkb || @game.gkb.owner != entity

            ability = @game.abilities(entity, :assign_hexes)
            return if !ability || ability.count.zero?

            ability
          end

          def process_assign(action)
            entity = action.entity
            ability = ability(entity)
            target = action.target
            assign_gkb_bonus(entity, target, ability, amount(ability))
          end

          def blocks?
            @game.gkb&.owner && @round.current_operator == @game.gkb.owner && ability(@round.current_operator)
          end

          def available_hex(_entity, hex)
            return unless @game.gkb_hexes.include?(hex)
            return if @game.gkb_hex_assigned?(hex)

            @game.hex_by_id(hex.id).neighbors.keys
          end

          def assign_gkb_bonus(entity, target, ability, amount)
            target.assign!("GKB#{amount}")
            amount_str = @game.format_currency(amount)
            ability.use!
            @game.log << "#{entity.name} assignes a Göta kanal #{amount_str} token to hex #{target.name}"
          end

          def amount(ability)
            case ability.count
            when 3
              50
            when 2
              30
            else
              20
            end
          end
        end
      end
    end
  end
end
