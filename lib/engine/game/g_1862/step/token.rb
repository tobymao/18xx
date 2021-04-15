# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1862
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if entity.corporation? && entity.receivership?

            super
          end

          def description
            @round.num_laid_track.zero? ? 'Add Token/Rail Link' : 'Add Token'
          end

          def can_place_token?(entity)
            current_entity == entity &&
              !@round.tokened &&
              !available_tokens(entity).empty? &&
              (@game.graph.can_token?(entity) || can_token_london?(entity))
          end

          def can_token_london?(entity)
            @round.num_laid_track.zero? && !@game.london_link?(entity)
          end

          def place_token(entity, city, token, connected: true, extra_action: false,
                          special_ability: nil, check_tokenable: true)
            hex = city.hex
            return super unless @game.class::LONDON_HEXES.include?(hex.id)

            raise GameError, 'Cannot build rail link after laying track' unless @round.num_laid_track.zero?
            raise GameError, 'Token/rail link already placed this turn' if @round.tokened
            raise GameError, 'Already built rail link to London' if @game.london_link?(entity)
            raise GameError, 'Token is already used' if token.used

            city.place_token(entity, token, free: true, check_tokenable: check_tokenable)

            @log << "#{entity.name} builds a rail link to London"

            @round.tokened = true
          end

          def available_hex(entity, hex)
            @game.graph.reachable_hexes(entity)[hex] ||
              (@game.class::LONDON_HEXES.include?(hex.id) && can_token_london?(entity))
          end
        end
      end
    end
  end
end
