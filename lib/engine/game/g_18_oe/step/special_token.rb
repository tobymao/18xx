# frozen_string_literal: true

require_relative '../../../step/special_token'
require_relative 'skip_abbreviated_round'
require_relative 'validated_token_cost'
require_relative 'track_rights_tokener'

module Engine
  module Game
    module G18OE
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          include SkipAbbreviatedRound
          include ValidatedTokenCost
          include TrackRightsTokener

          def available_hex(entity, hex)
            return pass_through_available_hex(entity, hex) if pass_through_ability?(entity)
            return super unless connected_ability?(entity)
            return true if @game.loading

            track_rights_available_hex(@game.token_owner(entity), hex)
          end

          def available_tokens(entity)
            return [pass_through_token(entity)] if pass_through_ability?(entity)
            return super unless connected_ability?(entity)

            [@game.token_owner(entity).tokens.reject(&:used).max_by(&:price)].compact
          end

          def process_place_token(action)
            return process_pass_through_token(action) if pass_through_ability?(action.entity)

            if connected_ability?(action.entity)
              operator = @game.token_owner(action.entity)
              action.token = available_tokens(action.entity).first
              check_connected(operator, action.city, action.city.hex)
              action.cost = recorded_fee(action, operator) unless @game.loading
              if !@game.loading && operator.cash < action.cost
                raise GameError, "#{operator.name} cannot afford the #{@game.format_currency(action.cost)} token cost"
              end

              charter_price = action.token.price
              action.token.price = action.cost
            end

            super
            @game.remove_wcf_placeholder! if action.entity.id == 'WCF'
          ensure
            action.token.price = charter_price if charter_price
          end

          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            return super if !special_ability || !connected?(special_ability)

            [token, special_ability]
          end

          private

          def pass_through_ability?(entity)
            @game.pass_through_token_company?(entity) && !ability(entity).nil?
          end

          def pass_through_token(entity)
            operator = @game.token_owner(entity)
            Engine::Token.new(operator, price: 0, logo: @game.pass_through_token_logo(entity), type: :pass_through)
          end

          def pass_through_available_hex(entity, hex)
            operator = @game.token_owner(entity)
            return false unless @game.pass_through_hex?(entity, hex)

            hex.tile.cities.none? { |city| city.tokened_by?(operator) || city.reserved_by?(operator) }
          end

          def process_pass_through_token(action)
            company = action.entity
            city = action.city
            hex = city.hex
            unless pass_through_available_hex(company, hex)
              raise GameError, "#{company.name} cannot place its token on #{hex.name}"
            end

            @game.place_pass_through_token!(company, @game.token_owner(company), city)
            ability(company).use!
          end

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
