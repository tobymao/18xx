# frozen_string_literal: true

require_relative '../../corporation'
require_relative '../../token'

module Engine
  module Game
    module GFrost1831
      # Each Favor or new base takes a token out of Parliament and moves the Faction
      # right, so its track position counts the tokens spent. Only bases are real tokens.
      class Faction < Engine::Corporation
        TOKENS = 9

        attr_accessor :bases_lost

        def initialize(**opts)
          super
          @bases_lost = 0
        end

        def tokens_spent
          share_price&.coordinates&.[](1) || 0
        end

        def tokens_available
          [TOKENS - 1 - tokens_spent, 0].max
        end

        def tokens_in_parliament
          home_placed = @tokens.any?(&:used) || @bases_lost.positive?
          tokens_available + (home_placed ? 0 : 1)
        end

        def tokens_total
          TOKENS - @bases_lost
        end

        # The views offer the first certificate in Parliament; the President's
        # goes last so they show a plain "Parliament Share" (the President's
        # certificate is still the first one handed out)
        def ipo_shares
          super.partition { |share| !share.president }.flatten
        end

        def find_token_by_type(type = nil)
          super || next_base
        end

        def tokens_by_type
          unplaced = super
          unplaced.empty? ? [next_base] : unplaced
        end

        def next_base
          @next_base = nil if @next_base&.used
          @next_base ||= BaseToken.new(self, price: 0)
        end

        class BaseToken < Engine::Token
          def place(location, extra: nil, cheater: nil)
            corporation.tokens << self unless corporation.tokens.include?(self)
            super
          end
        end
      end
    end
  end
end
