# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1873
      module Step
        class Token < Engine::Step::Token
          TOKEN_REPLACE_COST = 50

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless @game.railway?(entity)
            return [] if entity.receivership?
            return [] unless can_place_token?(entity)

            ACTIONS
          end

          def skip!
            log_skip(current_entity) if !@acted && current_entity && @game.railway?(current_entity)
            pass!
          end

          def can_place_token?(entity)
            current_entity == entity &&
              !@round.tokened &&
              !available_tokens(entity).empty? &&
              entity.cash >= TOKEN_REPLACE_COST
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city
            slot = action.slot
            token = action.token
            hex = city.hex
            tile = hex.tile

            if !@game.loading && !@game.graph.connected_nodes(entity)[city]
              city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
              raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
            end

            raise GameError, 'Token is already used' if token.used
            raise GameError, 'No token available to place' unless (new_token = entity.unplaced_tokens.first)

            if tile.cities.any? { |c| c.tokened_by?(entity) }
              raise GameError, "Cannot lay on #{hex.id}. Can only have one token per hex"
            end

            token.status = nil
            if (old_token = city.tokens[slot])&.status == :flipped && old_token&.corporation != entity
              # replace token
              #
              raise GameError, 'Cannot pay cost to replace a token' if entity.cash < TOKEN_REPLACE_COST

              old_token.remove!
              old_token.status = nil
              city.exchange_token(new_token)

              entity.spend(TOKEN_REPLACE_COST, old_token.corporation)
              @game.log << "#{entity.name} replaces #{old_token.corporation.name} token on #{hex.id} for "\
                           "#{@game.format_currency(TOKEN_REPLACE_COST)} (paid to #{old_token.corporation.name})"

              @round.tokened = true
              @game.graph.clear
            else
              # place new token
              #
              if @game.concession_blocks?(city)
                raise GameError, "Cannot lay on #{city.id}. Must leave room for concession RR"
              end

              super
            end

            @game.diesel_graph.clear
          end

          def can_replace_token?(_entity, token)
            token.status == :flipped
          end
        end
      end
    end
  end
end
