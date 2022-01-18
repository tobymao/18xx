# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1866
      module Step
        class Track < Engine::Step::Track
          def available_hex(entity, hex)
            return nil if @game.national_corporation?(entity) && !@game.hex_within_national_region?(entity, hex)
            return nil if @game.public_corporation?(entity) && !@game.hex_operating_rights?(entity, hex)

            super
          end

          def can_lay_tile?(entity)
            action = get_tile_lay(entity)
            return false unless action
            return true if @game.national_corporation?(entity)

            !entity.tokens.empty? && (buying_power(entity) >= action[:cost]) && (action[:lay] || action[:upgrade])
          end

          def process_lay_tile(action)
            entity = action.entity
            hex = action.hex
            if @game.national_corporation?(entity) && !@game.hex_within_national_region?(entity, hex)
              raise GameError, 'Cannot lay or upgrade tiles outside the nationals region'
            end
            if @game.public_corporation?(entity) && !@game.hex_operating_rights?(entity, hex)
              raise GameError, 'Cannot lay or upgrade tiles without operating rights in the selected region'
            end

            super
          end
        end
      end
    end
  end
end
