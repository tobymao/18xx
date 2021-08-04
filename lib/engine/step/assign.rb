# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Assign < Base
      ACTIONS = %w[assign].freeze

      def actions(entity)
        return [] unless entity.company?
        return ACTIONS if @game.abilities(entity, :assign_hexes) ||
                          @game.abilities(entity, :assign_corporation)

        []
      end

      def process_assign(action)
        company = action.entity
        target = action.target
        raise GameError, "#{company.name} is already assigned to #{target.name}" if target.assigned?(company.id)

        case target
        when Hex
          unless (ability = @game.abilities(company, :assign_hexes))
            raise GameError, "Could not assign #{company.name} to #{target.name}; :assign_hexes ability not found"
          end

          assignable_hexes = ability.hexes.map { |h| @game.hex_by_id(h) }
          Assignable.remove_from_all!(assignable_hexes, company.id) do |unassigned|
            @log << "#{company.name} is unassigned from #{unassigned.name}"
          end
          target.assign!(company.id)
          ability.use!
          @log << "#{company.name} is assigned to #{target.name}"
        when Corporation, Minor
          if assignable_corporations(company).include?(target) &&
             (ability = @game.abilities(company, :assign_corporation))
            Assignable.remove_from_all!(assignable_corporations, company.id) do |unassigned|
              @log << "#{company.name} is unassigned from #{unassigned.name}"
            end
            target.assign!(company.id)
            ability.use!
            @log << "#{company.name} is assigned to #{target.name}"
          else
            raise GameError, "Could not assign #{company.name} to #{target.name}; no assignable corporations found"
          end
        else
          raise GameError, "Invalid target #{target} for assigning company #{company.name}"
        end
      end

      def assignable_corporations(company = nil)
        @game.corporations.select { |c| c.floated? && !c.assigned?(company&.id) }
      end

      def available_hex(entity, hex)
        return unless entity.company?
        return unless @game.abilities(entity, :assign_hexes)&.hexes&.include?(hex.id)
        return if hex.assigned?(entity.id)

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def blocks?
        false
      end
    end
  end
end
