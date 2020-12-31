# frozen_string_literal: true

module Engine
  module Step
    module TokenMerger
      def tokens_in_same_hex(surviving, others)
        # Are there tokens in the same hex?
        # Most will be released by remove_duplicate_tokens, but NY style tiles need to be solved by the user
        (surviving.tokens.map { |t| t.city&.hex } & others_tokens(others).map { |t| t.city&.hex }).any?
      end

      def tokens_above_limits?(surviving, others)
        tokens_in_same_hex(surviving, others) ||
        (surviving.tokens + others_tokens(others)).select(&:used).size > @game.class::LIMIT_TOKENS_AFTER_MERGER
      end

      def others_tokens(others)
        others = Array(others)
        others.flat_map(&:tokens)
      end

      def remove_duplicate_tokens(surviving, others)
        # If there are 2 station markers on the same city the
        # surviving company must remove one and place it on its charter.
        # In the case of NY tiles this is ambigious and must be solved by the user

        others = others_tokens(others).map(&:city).compact
        surviving.tokens.each do |token|
          city = token.city
          token.remove! if others.include?(city)
        end
      end

      def round_state
        {
          corporations_removing_tokens: nil,
        }
      end

      def move_tokens_to_surviving(surviving, others)
        # Moves tokens to surviving company and returns a list of those moved

        # Seperate unused tokens to allow them to be moved to the end
        used, unused = surviving.tokens.partition(&:used)

        tokens = others_tokens(others).map do |token|
          new_token = Engine::Token.new(surviving)
          if token.city
            used << new_token
            token.swap!(new_token)
          else
            unused << new_token
          end
          new_token.city&.hex&.id
        end

        raise GameError, 'Used token above limit' if used.size > @game.class::LIMIT_TOKENS_AFTER_MERGER

        surviving.tokens.clear
        surviving_tokens = used + unused

        # Dump unused tokens above limit
        surviving.tokens.concat(surviving_tokens.slice(0, @game.class::LIMIT_TOKENS_AFTER_MERGER))

        # Owner may no longer have a valid route.
        @game.graph.clear_graph_for(surviving)

        tokens
      end
    end
  end
end
