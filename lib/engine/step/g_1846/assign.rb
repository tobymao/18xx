# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G1846
      class Assign < Assign
        ACTIONS_WITH_PASS = %w[assign pass].freeze

        def setup
          @steamboat = @game.steamboat
        end

        def assignable_corporations(company = nil)
          @game.minors.select { |m| m.floated? && !m.assigned?(company&.id) } + super
        end

        def blocking_for_steamboat?
          return false unless @round.operating?
          return false unless @steamboat.owned_by_player?
          return true if steamboat_assignable_to_corp?
          return true if steamboat_assignable_to_hex?

          false
        end

        def actions(entity)
          return super unless blocking_for_steamboat?

          ACTIONS_WITH_PASS
        end

        def description
          return super unless blocking_for_steamboat?

          'Assign Steamboat Company'
        end

        def steamboat_assigned_hex
          @game.hexes.find { |h| h.assigned?(@steamboat.id) }
        end

        def steamboat_assigned_corp
          assignable_corporations.find { |c| c.assigned?(@steamboat.id) }
        end

        def steamboat_assignable_to_corp?
          return false unless @steamboat.abilities(:assign_corporation)

          assignable_corporations(@steamboat).any?
        end

        def steamboat_assignable_to_hex?
          return false unless @steamboat.abilities(:assign_hexes)
          return true if steamboat_assigned_corp

          steamboat_assignable_to_corp?
        end

        def help
          return super unless blocking_for_steamboat?

          assignments = [steamboat_assigned_hex, steamboat_assigned_corp].compact.map(&:name)

          targets = []
          targets << 'hex' if steamboat_assignable_to_hex?
          targets << 'corporation or minor' if steamboat_assignable_to_corp?

          help_text = ["#{@steamboat.owner.name} may assign Steamboat Company to a new #{targets.join(' and/or ')}."]
          help_text << " Currently assigned to #{assignments.join(' and ')}." if assignments.any?

          help_text
        end

        def pass_description
          'Skip Assign'
        end

        def active_entities
          blocking_for_steamboat? ? [@steamboat] : super
        end

        def active?
          blocking_for_steamboat? || super
        end

        def blocks?
          blocking_for_steamboat?
        end

        def pass!
          super
          @round.start_operating
        end

        def process_assign(action)
          super
          @round.start_operating if (action.entity == @steamboat) &&
                                    @steamboat.owned_by_player? &&
                                    !blocking_for_steamboat?
        end

        def process_pass(action)
          @game.game_error("Not #{action.entity.name}'s turn: #{action.to_h}") unless action.entity == @steamboat

          if (ability = @steamboat.abilities(:assign_hexes))
            ability.use!
            if (hex = steamboat_assigned_hex)
              @log.action! "is assigned to #{hex.name}"
            else
              @log.action! 'is not assigned to any hex'
            end
          end

          if (ability = @steamboat.abilities(:assign_corporation))
            ability.use!
            if (corp = steamboat_assigned_corp)
              @log.action! "is assigned to #{corp.name}"
            else
              @log.action! 'is not assigned to any corporation or minor'
            end
          end

          pass!
        end
      end
    end
  end
end
