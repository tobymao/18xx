# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1866
      module Step
        class Token < Engine::Step::Token
          def available_hex(entity, hex)
            return nil if @game.public_corporation?(entity) && !@game.hex_operating_rights?(entity, hex)

            super
          end

          def log_skip(entity)
            return if @game.national_corporation?(entity)

            @log << "#{entity.name} skips place a token"
          end

          def process_place_token(action)
            entity = action.entity
            hex = action.city.hex
            if @game.public_corporation?(entity) && !@game.hex_operating_rights?(entity, hex)
              raise GameError, 'Cannot place token without operating rights in the selected region'
            end

            super
          end
        end
      end
    end
  end
end
