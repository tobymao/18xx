# frozen_string_literal: true

require_relative '../../../step/special_token'
require_relative 'skip_abbreviated_round'
require_relative 'track_rights_tokener'

module Engine
  module Game
    module G18OE
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          include SkipAbbreviatedRound
          include TrackRightsTokener

          def available_hex(entity, hex)
            return super unless connected_ability?(entity)
            return true if @game.loading

            track_rights_available_hex(@game.token_owner(entity), hex)
          end

          def available_tokens(entity)
            return super unless connected_ability?(entity)

            [@game.token_owner(entity).tokens.reject(&:used).max_by(&:price)].compact
          end

          def process_place_token(action)
            if connected_ability?(action.entity)
              operator = @game.token_owner(action.entity)
              action.token = available_tokens(action.entity).first
              check_connected(operator, action.city, action.city.hex)
              action.cost = recorded_fee(action, operator) unless @game.loading
              if !@game.loading && operator.cash < action.cost
                raise GameError, "#{operator.name} cannot afford the #{@game.format_currency(action.cost)} token cost"
              end

              action.token.price = action.cost
            end

            super
            @game.remove_wcf_placeholder! if action.entity.id == 'WCF'
          end

          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            return super if !special_ability || !connected?(special_ability)

            [token, special_ability]
          end

          private

          def connected_ability?(entity)
            ability = ability(entity)
            !ability.nil? && connected?(ability)
          end

          def connected?(ability)
            ability.type == :token && ability.connected
          end

          def recorded_fee(action, operator)
            validated_token_cost(action, @game.cross_water_token_fee(operator, action.city))
          end
        end
      end
    end
  end
end
