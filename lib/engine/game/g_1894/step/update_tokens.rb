# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1894
      module Step
        class UpdateTokens < Engine::Step::Base
          def actions(entity)
            @saved_tokens = @game.saved_tokens
            hex = @game.saved_tokens_hex

            return [] unless @saved_tokens
            return [] if hex.tile.cities.flat_map(&:tokens).compact.size == @saved_tokens.size
            
            # token = @saved_tokens[0]
            # @hex = @game.saved_tokens_hex
            # @round.pending_tokens << {
            #   entity: token.corporation,
            #   hexes: [@hex],
            #   token: token,
            # }
            # @log << "#{token.corporation.name} must choose city for token"
            # @saved_tokens.delete(token)

            # if @saved_tokens == []
            #   pass!
            # end

            #@game.save_tokens(@saved_tokens)

            #@game.operating_order.each do |

            @saved_tokens.each do |token|
              @round.pending_tokens << {
                entity: token.corporation,
                hexes: [@game.saved_tokens_hex],
                token: token,
              }
              @log << "#{token.corporation.name} must choose city for token"
            end

            #%w[hex_token]
          end

          def pending_entity
            @game.saved_tokens[0].token.corporation if @game.save_tokens
          end

          def description
            'Choose city for token'
          end

          # def active?
          #   true
          # end

          def process_hex_token(action)
            @saved_tokens.each do |token|
              @round.pending_tokens << {
                entity: token.corporation,
                hexes: [@game.saved_tokens_hex],
                token: token,
              }
              @log << "#{token.corporation.name} must choose city for token"
              @saved_tokens.delete(token)
            end
  
            # @game.save_tokens(nil)
            # @game.graph.clear
            # entity = action.entity
            # hex = action.hex
            # # This ignores the token on the action, as for a few games it was incorrectly set to a 'normal' token
            # token = available_tokens(entity).first
            # raise GameError, 'Corporation does not have a destination token unused' unless token

            # if !@game.loading && !destination_node_check?(entity)
            #   raise GameError, "Can't place the destination token on #{hex.name} "\
            #                    'because it is not connected'
            # end

            # @game.place_destination_token(entity, hex, token)
            # pass!
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
