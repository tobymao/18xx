# frozen_string_literal: true

require_relative '../../../step/home_token'
require_relative 'corp_start'

module Engine
  module Game
    module G1841
      module Step
        class HomeToken < Engine::Step::HomeToken
          include CorpStart
          def actions(entity)
            return [] unless entity == pending_entity
            return %w[place_token pass] if can_pass?

            ACTIONS
          end

          def can_pass?
            @round.pending_tokens.one? && @game.major?(token.corporation)
          end

          def pass!
            @round.pending_tokens.shift
            post_token_lay_step!
          end

          def process_place_token(action)
            super
            unless @round.pending_tokens.empty?
              # update legal token locations now that the first token has been placed
              legal_hexes = @game.home_token_locations(token.corporation)
              if legal_hexes.empty?
                # nowhere to place a token => bail on the 2nd token
                @log << "No legal second token location for #{token.corporation.name}"
                @round.pending_tokens.shift
              else
                @round.pending_tokens.first[:hexes] = legal_hexes
              end
            end

            post_token_lay_step! if @round.pending_tokens.empty?
          end
        end
      end
    end
  end
end
