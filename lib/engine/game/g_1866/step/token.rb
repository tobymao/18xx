# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1866
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if @game.game_end_triggered_last_round?

            super
          end

          def available_hex(entity, hex)
            return nil if @game.corporation?(entity) && !@game.hex_operating_rights?(entity, hex)

            super
          end

          def buying_power(entity)
            @game.buying_power_with_loans(entity)
          end

          def log_skip(entity)
            return if @game.national_corporation?(entity)

            if @game.game_end_triggered_last_round?
              @log << "Last round, #{entity.name} may not lay any tokens"
              return
            end

            @log << "#{entity.name} skips place a token"
          end

          def process_place_token(action)
            entity = action.entity
            hex = action.city.hex
            token = action.token
            if @game.corporation?(entity) && !@game.hex_operating_rights?(entity, hex)
              raise GameError, 'Cannot place token without operating rights in the selected region'
            end

            try_take_loan(entity, token.price)
            super
          end

          def try_take_loan(entity, price)
            return if !price.positive? || price <= entity.cash

            @game.take_loan(entity) while entity.cash < price
          end
        end
      end
    end
  end
end
