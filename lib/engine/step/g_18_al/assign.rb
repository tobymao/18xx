# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G18AL
      class Assign < Assign
        def process_assign(action)
          company = action.entity
          @game.game_error("#{company.owner.name} is not SNAR") if company != @game.south_and_north_alabama_railroad
          @game.game_error("#{company.owner.name} owns no trains") if company.owner.trains.empty?

          target = action.target
          hexes = company.abilities(:assign_hexes)&.hexes
          location = @game.get_location_name(target.id)
          if !@game.loading && @game.graph.reachable_hexes(company.owner).find { |h, _| h.id == target.id }.nil?
            @game.game_error("#{location} is not reachable")
          end

          super

          # Add a revenue bonus for the corporation
          # that will be removed in phase 6
          ability = Engine::Ability::HexBonus.new(
            type: :hexes_bonus,
            description: "Warrior Coal Field token: #{location}",
            hexes: [target.id],
            amount: 10
          )
          company.owner.add_ability(ability)
          @game.remove_mining_icons(hexes)

          @log << "Warrior Coal Field token is placed in #{location} (#{target.id})"

          # Skip warning if corporation has token in assigned city
          return if company.owner.tokens.any? { |t| t.city && t.city.hex.name == target.id }

          # TODO: the following note can be removed when this can be done automatically
          @log << "-- Note! It is not verified that #{company.owner.name} owns a train that can run to #{location}"
          @log << "-- Please undo the assign of Warrior Coal Field token to #{location} if it is not legal"
        end
      end
    end
  end
end
