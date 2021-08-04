# frozen_string_literal: true

require_relative '../../../step/assign'
require_relative '../../../game_error'

module Engine
  module Game
    module G18SJ
      module Step
        class Assign < Engine::Step::Assign
          ACTIONS_WITH_PASS = %w[assign pass].freeze

          def setup
            @sveabolaget = @game.sveabolaget
          end

          def blocking_for_sveabolaget?
            return false unless @round.operating?
            return false unless @sveabolaget&.owned_by_player?
            return true if sveabolaget_assignable_to_hex?

            false
          end

          def actions(entity)
            return super unless blocking_for_sveabolaget?

            ACTIONS_WITH_PASS
          end

          def description
            return super unless blocking_for_sveabolaget?

            "Assign #{@sveabolaget.name}"
          end

          def sveabolaget_assigned_hex
            @game.hexes.find { |h| h.assigned?(@sveabolaget.id) }
          end

          def sveabolaget_assignable_to_hex?
            return false unless @game.abilities(@sveabolaget, :assign_hexes)
            return true if sveabolaget_assigned_corp

            sveabolaget_assignable_to_corp?
          end

          def help
            return super unless blocking_for_sveabolaget?

            assignments = [sveabolaget_assigned_hex].compact.map(&:name)

            targets = []
            targets << 'hex' if sveabolaget_assignable_to_hex?

            help_text = ["#{@sveabolaget.owner.name} may assign #{@sveabolaget.name} to a new hex."]
            help_text << " Currently assigned to #{assignments}." if assignments.any?

            help_text
          end

          def pass_description
            'Skip Assign'
          end

          def active_entities
            blocking_for_sveabolaget? ? [@sveabolaget] : super
          end

          def active?
            blocking_for_sveabolaget? || super
          end

          def blocks?
            blocking_for_sveabolaget?
          end

          def pass!
            super
            @round.start_operating
          end

          def process_assign(action)
            super
            @round.start_operating if (action.entity == @sveabolaget) &&
                                      @sveabolaget.owned_by_player? &&
                                      !blocking_for_sveabolaget?
          end

          def process_pass(action)
            raise GameError "Not #{action.entity.name}'s turn: #{action.to_h}" unless action.entity == @sveabolaget

            if (ability = @game.abilities(@sveabolaget, :assign_hexes))
              ability.use!
              @log <<
                if (hex = sveabolaget_assigned_hex)
                  "#{@sveabolaget.name} is assigned to #{hex.name}"
                else
                  "#{@sveabolaget.name} is not assigned to any hex"
                end
            end

            pass!
          end
        end
      end
    end
  end
end
