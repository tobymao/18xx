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
          if !@game.loading && @game.graph.reachable_hexes(company.owner).find { |h, _| h.id == target.id }.nil?
            @game.game_error("#{@game.get_location_name(target.id)} is not reachable")
          end

          super

          # Add a revenue bonus for the corporation
          # that will be removed in phase 6
          ability = Engine::Ability::HexBonus.new(
            type: :hexes_bonus,
            description: "Coal Field token: #{@game.get_location_name(target.id)}",
            hexes: [target.id],
            amount: 10
          )
          company.owner.add_ability(ability)
          @game
            .hexes
            .select { |hex| hexes.include?(hex.name) }
            .each { |hex| hex.tile.icons = [] }
        end
      end
    end
  end
end
