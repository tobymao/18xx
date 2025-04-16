# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1837
      module Step
        class Track < Engine::Step::Track
          include SkipReceivership

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            tile = action.tile
            case tile.name
            when '435'
              corp = @game.corporation_by_id('UG')
            when '436'
              corp = @game.corporation_by_id('KK')
            end
            if corp
              # Keep home token - index 0
              corp.tokens[1..-1].select { |token| token.city.hex == action.hex }.each_with_index do |token, i|
                token.remove!
                token.price = i.zero? ? 20 : 40
              end
            end
            super
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.class::YELLOW_DOUBLE_TOWN_UPGRADES.include?(new_tile.name)

            super
          end
        end
      end
    end
  end
end
