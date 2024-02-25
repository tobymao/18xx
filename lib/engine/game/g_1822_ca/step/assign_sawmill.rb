# frozen_string_literal: true

require_relative '../../../step/assign'

module Engine
  module Game
    module G1822CA
      module Step
        class AssignSawmill < Engine::Step::Assign
          ASSIGN_ACTIONS = %w[assign].freeze
          CHOOSE_ACTIONS = %w[choose].freeze

          def actions(entity)
            @sawmill_state ||= :none
            return CHOOSE_ACTIONS if @sawmill_state == :assigned

            super
          end

          def description
            'sawmill'
          end

          def blocks?
            @sawmill_state == :assigned
          end

          def process_assign(action)
            @sawmill_owner = action.entity.owner
            @sawmill_state = :assigned
            @sawmill_hex = action.target
            @game.sawmill_hex = @sawmill_hex
            super
          end

          def process_choose(action)
            raise GameError, 'Cannot choose if Sawmill is not assigned' unless @sawmill_state == :assigned

            case action.choice
            when 'open'
              @game.sawmill_bonus = 20
              @log << "Open Sawmill token placed on #{@sawmill_hex.id} (#{@sawmill_hex.location_name}) for a $20 bonus "\
                      "to the total revenue of any corporation\'s routes that include that location"

            when 'closed'
              @game.sawmill_bonus = 10
              @game.sawmill_owner = @sawmill_owner
              new_ability = Ability::Base.new(
                type: 'base',
                description: "Sawmill: +$10 for one train on #{@sawmill_hex.id}",
              )
              @sawmill_owner.add_ability(new_ability)

              @log << "Closed Sawmill token placed on #{@sawmill_hex.id} (#{@sawmill_hex.location_name}) for a $10 bonus "\
                      "to the total revenue of #{@sawmill_owner.name}\'s routes which include that location"
            else
              raise GameError, "Invalid choice for Sawmill: #{action.choice}"
            end

            @sawmill_state = :chosen
            pass!
          end

          # make sure the hex is not a town that was removed by P29 or P30
          def available_hex(entity, hex)
            super && !(hex.tile.cities + hex.tile.towns).empty?
          end

          def choices
            if @sawmill_state == :assigned
              {
                'open' => 'Open: +$20 for everyone',
                'closed' => "Closed: +$10 only for #{@sawmill_owner&.name}",
              }
            else
              {}
            end
          end

          def choice_name
            'Choose the Sawmill token'
          end
        end
      end
    end
  end
end
