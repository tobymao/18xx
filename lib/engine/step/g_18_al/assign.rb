# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G18AL
      class Assign < Assign
        def process_assign(action)
          company = action.entity
          @game.game_error("#{company.owner.name} owns no trains") if company.owner.trains.empty?

          target = action.target
          hexes = company.abilities(:assign_hexes)&.hexes
          target_location = @game.get_location_name(target.id)
          if !@game.loading && @game.graph.reachable_hexes(company.owner).find { |h, _| h.id == target.id }.nil?
            @game.game_error("#{target_location} is not reachable")
          end

          super

          # Add a revenue bonus for the corporation
          # that will be removed in phase 6
          ability = Engine::Ability::HexBonus.new(
            type: :hexes_bonus,
            description: "Warrior Coal Field token: #{target_location}",
            hexes: [target.id],
            amount: 10
          )
          company.owner.add_ability(ability)
          @game
            .hexes
            .select { |hex| hexes.include?(hex.name) }
            .each { |hex| hex.tile.icons = [] }

          @log << "Warrior Coal Field token is placed in #{target_location} (#{target.id})"
          # TODO: the following note can be removed when this can be done automatically
          @log << "Note! It is not verified that #{company.owner.name} owns a train that can run to #{target_location}"
          @log << "Please undo the assign of Warrior Coal Field token to #{target_location} if it is not legal"
        end
      end
    end
  end
end
