# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'skip_abbreviated_round'
require_relative 'track_rights_tokener'

module Engine
  module Game
    module G18OE
      module Step
        class Token < Engine::Step::Token
          include SkipAbbreviatedRound
          include TrackRightsTokener

          def actions(entity)
            return [] if skip?
            return ACTIONS if entity == current_entity && !@round.tokened && token_ability?(entity)

            super
          end

          def available_hex(entity, hex)
            track_rights_available_hex(entity, hex)
          end

          def process_place_token(action)
            action.cost = token_cost(action) unless @game.loading
            action.token.price = action.cost
            super
          end

          private

          def token_ability?(entity)
            pass_through_ability?(entity) || unconnected_token_ability?(entity)
          end

          def pass_through_ability?(entity)
            @game.abilities(entity, :token) { |ability| return true if @game.pass_through_token_company?(ability.owner) }
            false
          end

          def unconnected_token_ability?(entity)
            return false unless entity.next_token

            @game.abilities(entity, :token) { |ability| return true unless ability.connected }
            false
          end

          def token_cost(action)
            validated_token_cost(action, action.token.price + @game.cross_water_token_fee(action.entity, action.city))
          end
        end
      end
    end
  end
end
