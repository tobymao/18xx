# frozen_string_literal: true

require_relative '../../../step/token'
require_relative 'skip_abbreviated_round'
require_relative 'station_token_selection'
require_relative 'track_rights_tokener'

module Engine
  module Game
    module G18OE
      module Step
        class Token < Engine::Step::Token
          include SkipAbbreviatedRound
          include StationTokenSelection
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
            entity = action.entity
            token = selected_token(action)
            raise GameError, 'Select an available station token from the charter' unless available_station_token?(entity, token)

            cost = token_cost(action, token)
            raise GameError, "#{entity.name} cannot afford the #{@game.format_currency(cost)} token cost" if cost > entity.cash

            @game.check_reserved_train_funds!(entity, cost)

            charter_price = token.price
            action.token = token
            action.cost = cost
            token.price = cost
            super
          ensure
            token.price = charter_price if charter_price
          end

          private

          def station_token_fee(entity, city)
            @game.cross_water_token_fee(entity, city)
          end

          def token_cost(action, token)
            raise GameError, 'Include the station token cost' if !action.token_index.nil? && !action.cost.is_a?(Integer)
            return action.cost if @game.loading

            validated_token_cost(action, token.price + station_token_fee(action.entity, action.city))
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
