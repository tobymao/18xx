# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/tokener'
require_relative 'skip_abbreviated_round'
require_relative 'station_token_selection'

module Engine
  module Game
    module G18OE
      module Step
        class TransferTokens < Engine::Step::Base
          include Engine::Step::Tokener
          include SkipAbbreviatedRound
          include StationTokenSelection

          def actions(entity)
            return [] if skip?
            return [] if entity != current_entity || !entity.corporation? || entity.type != :major

            actions = []
            actions << 'place_token' if token_purchasable?(entity)
            actions << 'choose' unless @game.port_authority_sales(entity).empty?
            actions << 'pass' unless actions.empty?
            actions
          end

          def choice_name
            'Port authority'
          end

          def choices
            @game.port_authority_sales(current_entity).to_h do |seller, sea|
              [
                @game.port_authority_sale_key(seller, sea),
                "Buy #{@game.port_authority_name(sea)} from #{seller.name} (#{@game.format_currency(@game.port_authority_cost)})",
              ]
            end
          end

          def process_choose(action)
            buyer = action.entity
            sale = @game.port_authority_sale(buyer, action.choice)
            raise GameError, "Invalid port authority purchase: #{action.choice}" unless sale

            @game.transfer_port_authority!(buyer, *sale)
          end

          def description
            'Transfer Tokens'
          end

          def pass_description
            'Pass (Transfer Tokens)'
          end

          def log_skip(_entity); end

          def available_hex(entity, hex)
            hex.tile.cities.any? { |city| (city.tokens + city.extra_tokens).any? { |token| transferable?(entity, token) } }
          end

          def can_replace_token?(entity, token)
            transferable?(entity, token)
          end

          def token_cost_override(entity, city, _slot, token)
            return unless token

            token.price + station_token_fee(entity, city)
          end

          def process_place_token(action)
            buyer = action.entity
            new_token = selected_token(action)
            unless available_station_token?(buyer, new_token)
              raise GameError, 'Select an available station token from the charter'
            end

            city = action.city
            raise GameError, 'Select a station token to transfer' unless action.slot.is_a?(Integer)

            old_token = (city.tokens + city.extra_tokens)[action.slot]
            raise GameError, 'Select a station token that can be transferred' unless transferable?(buyer, old_token)

            cost = transfer_cost(action, new_token)
            raise GameError, "#{buyer.name} cannot afford the #{@game.format_currency(cost)} transfer cost" if cost > buyer.cash

            @game.transfer_token!(buyer, new_token, old_token, cost - new_token.price)
          end

          private

          def station_token_fee(_entity, city)
            @game.token_transfer_fee(city)
          end

          def transfer_cost(action, new_token)
            raise GameError, 'Include the transfer cost' unless action.cost.is_a?(Integer)

            return action.cost if @game.loading

            validated_token_cost(action, new_token.price + station_token_fee(action.entity, action.city))
          end

          def transferable?(entity, token)
            token && @game.transferable_token?(entity, token)
          end

          def token_purchasable?(entity)
            tokens = available_tokens(entity)
            return false if tokens.empty?

            cheapest = tokens.map(&:price).min
            @game.corporations.any? do |seller|
              seller.tokens.any? do |token|
                transferable?(entity, token) && cheapest + @game.token_transfer_fee(token.city) <= entity.cash
              end
            end
          end
        end
      end
    end
  end
end
