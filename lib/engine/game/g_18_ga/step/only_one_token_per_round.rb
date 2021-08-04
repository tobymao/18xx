# frozen_string_literal: true

module Engine
  module Game
    module G18GA
      module OnlyOneTokenPerRound
        def process_place_token(action)
          super
          @round.tokens_placed << entity_corporation(action.entity)
        end

        def entity_corporation(entity)
          return entity.owner if entity.company?

          entity
        end

        def already_tokened_this_round?(entity)
          @round.tokens_placed.include?(entity_corporation(entity))
        end

        def remaining_token_ability?(entity)
          corporation = entity_corporation(entity)
          return false if @game.p3_company.owner != corporation ||
                          !@game.abilities(@game.p3_company, :token)&.count&.positive?

          @game.waycross_hex.tile.cities.each do |c|
            return true if c.tokenable?(corporation, free: true)
          end
          false
        end

        def round_state
          super.merge({ tokens_placed: [] })
        end
      end
    end
  end
end
