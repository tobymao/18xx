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

        if target.is_a?(Hex) && company.abilities(:assign_hexes)
          target.assign!(company.id)
          company.abilities(:assign_hexes, &:use!)
          @log << "#{company.name} is assigned to #{target.name}"
        elsif target.is_a?(Corporation) && company.abilities(:assign_corporation)
          Assignable.remove_from_all!(@game.corporations, company.id) do |unassigned|
            @log << "#{company.name} is unassigned from #{unassigned.name}"
          end
          target.assign!(company.id)
          @log << "#{company.name} is assigned to #{target.name}"
        end
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
