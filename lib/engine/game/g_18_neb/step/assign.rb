# frozen_string_literal: true

require_relative '../../../step/assign'
require_relative '../../../game_error'

module Engine
  module Game
    module G18NEB
      module Step
        class Assign < Engine::Step::Assign
          ACTIONS_WITH_PASS = %w[assign pass].freeze

          def setup
            @armour = @game.armour
          end

          def blocking_for_armour?
            return false unless @round.operating?
            return false unless @armour&.owned_by_player?
            return true if armour_assignable_to_hex?

            false
          end

          def actions(entity)
            return super unless blocking_for_armour?

            ACTIONS_WITH_PASS
          end

          def description
            return super unless blocking_for_armour?

            "Assign #{@armour.name}"
          end

          def armour_assigned_hex
            @game.hexes.find { |h| h.assigned?(@armour.id) }
          end

          def armour_assignable_to_hex?
            return false unless @game.abilities(@armour, :assign_hexes)
            return true if armour_assigned_corp

            armour_assignable_to_corp?
          end

          def help
            return super unless blocking_for_armour?

            assignments = [armour_assigned_hex].compact.map(&:name)

            targets = []
            targets << 'hex' if armour_assignable_to_hex?

            help_text = ["#{@armour.owner.name} may assign #{@sveabolaget.name} to a new hex."]
            help_text << " Currently assigned to #{assignments}." if assignments.any?

            help_text
          end

          def pass_description
            'Skip Assign'
          end

          def active_entities
            blocking_for_armour? ? [@sveabolaget] : super
          end

          def active?
            blocking_for_armour? || super
          end

          def blocks?
            blocking_for_armour?
          end

          def pass!
            super
            @round.start_operating
          end

          def process_assign(action)
            super
            @round.start_operating if (action.entity == @armour) &&
                                      @armour.owned_by_player? &&
                                      !blocking_for_armour?
          end

          def process_pass(action)
            raise GameError "Not #{action.entity.name}'s turn: #{action.to_h}" unless action.entity == @armour

            if (ability = @game.abilities(@armour, :assign_hexes))
              ability.use!
              @log <<
                if (hex = armour_assigned_hex)
                  "#{@armour.name} is assigned to #{hex.name}"
                else
                  "#{@armour.name} is not assigned to any hex"
                end
            end

            pass!
          end
        end
      end
    end
  end
end
