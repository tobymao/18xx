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
            @log << "@sawmill_owner = #{@sawmill_owner.name}, #{@sawmill_owner}"
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
              @log << "#{action.entity.player.name} chooses the Open Sawmill "\
                      'token. It will provide a +$20 bonus for one train per '\
                      "turn at #{@sawmill_hex.id} (#{@sawmill_hex.location_name}), available to all Majors."

            when 'closed'
              @game.sawmill_bonus = 10
              @game.sawmill_owner = @sawmill_owner
              new_ability = Ability::Base.new(
                type: 'base',
                description: "Sawmill: +$10 for one train on #{@sawmill_hex.id}",
              )
              @sawmill_owner.add_ability(new_ability)

              @log << "#{action.entity.player.name} chooses the Closed Sawmill "\
                      'token. It will provide a +$10 bonus for one train per '\
                      "turn at #{@sawmill_hex.id} (#{@sawmill_hex.location_name}), "\
                      "exclusively for #{@sawmill_owner.name}."
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
