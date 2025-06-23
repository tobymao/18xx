# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module GSystem18
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            corporation = action.entity
            super

            # after placing token in chosen hex, must remove reservation in other hex
            @game.hexes.each do |hex|
              hex.tile.cities.each do |city|
                if city.reserved_by?(corporation)
                  city.reservations.delete(corporation)
                  @log << "Removing unused reservation for #{corporation.name} in #{hex.id}"
                end
              end
            end
          end
        end
      end
    end
  end
end
