# frozen_string_literal: true

module Engine
  module Step
    module G1817
      module TokenMerger
        def tokens_in_same_hex(surviving, other)
          # Are there tokens in the same hex?
          # Most will be released by remove_duplicate_tokens, but NY style tiles need to be solved by the user
          (surviving.tokens.map { |t| t.city&.hex } & other.tokens.map { |t| t.city&.hex }).any?
        end

        def tokens_above_limits?(surviving, other)
          tokens_in_same_hex(surviving, other) ||
          (surviving.tokens + other.tokens).select(&:used).size > @game.class::LIMIT_TOKENS
        end

        def remove_duplicate_tokens(surviving, other)
          # If there are 2 station markers on the same city the
          # surviving company must remove one and place it on its charter.
          # In the case of NY tiles this is ambigious and must be solved by the user
          other_tokens = other.tokens.map(&:city).compact
          surviving.tokens.each do |token|
            city = token.city
            token.remove! if other_tokens.include?(city)
          end
        end

        def round_state
          {
            corporations_removing_tokens: nil,
          }
        end

        def move_tokens_to_surviving(surviving, other)
          # Moves tokens to surviving company and returns a list of those moved

          # Seperate unused tokens to allow them to be moved to the end
          used, unused = surviving.tokens.partition(&:used)

          tokens = other.tokens.map do |token|
            new_token = Engine::Token.new(surviving)
            if token.city
              used << new_token
              token.swap!(new_token)
            else
              unused << new_token
            end
            new_token.city&.hex&.id
          end

          @game.game_error('Used token above limit') if used.size > @game.class::LIMIT_TOKENS

          surviving.tokens.clear
          surviving_tokens = used + unused

          # Dump unused tokens above limit
          surviving.tokens.concat(surviving_tokens.slice(0, @game.class::LIMIT_TOKENS))

          # Owner may no longer have a valid route.
          @game.graph.clear_graph_for(surviving)

          tokens
        end
      end
    end
  end
end
