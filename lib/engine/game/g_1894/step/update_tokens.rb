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
            #return [] if hex.tile.cities.flat_map(&:tokens).compact.size == @saved_tokens.size

            @saved_tokens.sort_by! { |t| @game.operating_order.index(t.corporation) }

            @saved_tokens.each do |token|
              @round.pending_tokens << {
                entity: token.corporation,
                hexes: [@game.saved_tokens_hex],
                token: token,
              }
              @log << "#{token.corporation.name} must choose city for token"

              @saved_tokens.delete(token)
              @game.save_tokens(@saved_tokens)
            end
          end

          def pending_entity
            @game.saved_tokens[0].token.corporation if @game.saved_tokens.any?
          end

          def description
            'Choose city for token'
          end

          # def process_hex_token(action)
          #   @saved_tokens.each do |token|
          #     @round.pending_tokens << {
          #       entity: token.corporation,
          #       hexes: [@game.saved_tokens_hex],
          #       token: token,
          #     }
          #     @log << "#{token.corporation.name} must choose city for token"
          #     @saved_tokens.delete(token)
          #   end
          # end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
