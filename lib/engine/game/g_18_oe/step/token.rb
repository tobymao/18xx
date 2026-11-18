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

          def available_tokens(entity)
            entity.tokens.select { |token| available_station_token?(entity, token) }.uniq(&:price)
          end

          def selectable_token_choices(entity, city)
            fee = @game.cross_water_token_fee(entity, city)
            available_tokens(entity).map do |token|
              { token: token, index: entity.tokens.index(token), cost: token.price + fee }
            end
          end

          def process_place_token(action)
            entity = action.entity
            token = selected_token(action)
            raise GameError, 'Select an available station token from the charter' unless available_station_token?(entity, token)

            cost = token_cost(action, token)
            raise GameError, "#{entity.name} cannot afford the #{@game.format_currency(cost)} token cost" if cost > entity.cash

            charter_price = token.price
            action.token = token
            action.cost = cost
            token.price = cost
            super
          ensure
            token.price = charter_price if charter_price && !token.used
          end

          private

          def available_station_token?(entity, token)
            token && !token.used && token.type == :normal && token.corporation == entity
          end

          def selected_token(action)
            index = action.token_index
            return action.token if index.nil?

            entity = action.entity
            return if !index.is_a?(Integer) || index.negative? || index >= entity.tokens.size

            entity.tokens[index]
          end

          def token_cost(action, token)
            raise GameError, 'Include the station token cost' if !action.token_index.nil? && !action.cost.is_a?(Integer)
            return action.cost if @game.loading

            validated_token_cost(action, token.price + @game.cross_water_token_fee(action.entity, action.city))
          end

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
        end
      end
    end
  end
end
