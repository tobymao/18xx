# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Assign < Base
      ACTIONS = %w[assign].freeze

      def actions(entity)
        return [] unless entity.company?
        return ACTIONS if entity.abilities(:assign_hexes) || entity.abilities(:assign_corporation)

        []
      end

      def process_assign(action)
        company = action.entity
        target = action.target
        @game.game_error("#{company.name} is already assigned to #{target.name}") if target.assigned?(company.id)

        case target
        when Hex
          if (ability = company.abilities(:assign_hexes))
            assignable_hexes = ability.hexes.map { |h| @game.hex_by_id(h) }
            Assignable.remove_from_all!(assignable_hexes, company.id) do |unassigned|
              @log << "#{company.name} is unassigned from #{unassigned.name}"
            end
            target.assign!(company.id)
            ability.use!
            @log << "#{company.name} is assigned to #{target.name}"
          else
            @game.game_error("Could not assign #{company.name} to #{target.name}; :assign_hexes ability not found")
          end
        when Corporation, Minor
          if assignable_corporations && (ability = company.abilities(:assign_corporation))
            Assignable.remove_from_all!(assignable_corporations, company.id) do |unassigned|
              @log << "#{company.name} is unassigned from #{unassigned.name}"
            end
            target.assign!(company.id)
            ability.use!
            @log << "#{company.name} is assigned to #{target.name}"
          else
            @game.game_error("Could not assign #{company.name} to #{target.name}; no assignable corporations found")
          end
        else
          @game.game_error("Invalid target #{target} for assigning company #{company.name}")
        end
      end

      def assignable_corporations
        @game.corporations
      end

      def available_hex(entity, hex)
        return unless entity.company?
        return unless entity.abilities(:assign_hexes)&.hexes&.include?(hex.id)

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def blocks?
        false
      end
    end
  end
end
