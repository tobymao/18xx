# frozen_string_literal: true

module Engine
  module Game
    module G1812
      module Tracker
        def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
          super
          hex_id = action.hex.id
          @game.companies.each do |company|
            laid = company.all_abilities.select { |a| a.type == :tile_lay && a.hexes.include?(hex_id) && all_laid?(a.hexes) }
            laid.each { |a| company.remove_ability(a) }
          end
        end

        def all_laid?(hex_ids)
          hex_ids.none? { |id| @game.hex_by_id(id)&.tile&.color == :white }
        end
      end
    end
  end
end
