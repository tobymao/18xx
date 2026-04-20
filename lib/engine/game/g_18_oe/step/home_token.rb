# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18OE
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            if action.entity.type == :minor
              hex = action.city.hex
              region = @game.class::CITY_NATIONAL_ZONE[hex.coordinates] ||
                       @game.class::NATIONAL_REGION_HEXES.find { |_, hexes| hexes.include?(hex.coordinates) }&.first

              raise GameError, "Region #{region} is not available" unless @game.minor_available_regions.key?(region)

              token.price = @game.class::TRACK_RIGHTS_COST[region] || 0

              @game.minor_available_regions[region] -= 1
              @game.minor_available_regions.delete(region) if @game.minor_available_regions[region].zero?

              if @game.class::ASTERISKED_ZONES.include?(region)
                @game.minor_asterisked_selected += 1
                if @game.minor_asterisked_selected >= @game.class::ASTERISKED_ZONES_CAP
                  @game.class::ASTERISKED_ZONES.each { |z| @game.minor_available_regions.delete(z) }
                end
              end

              @game.minor_floated_regions[action.entity.id] = region
            end

            super
          end
        end
      end
    end
  end
end
