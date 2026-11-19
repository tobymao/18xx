# frozen_string_literal: true

module Engine
  module Game
    module G1833NE
      module Step
        module TakeoverOffer
          def takeover
            @round.takeover
          end

          def holdings
            @game.takeover_holdings(takeover[:target])
          end

          def pending_holder_index
            return if !takeover || awaiting_consent?

            takeover[:swaps].size if takeover[:swaps].size < holdings.size
          end

          def swap_range
            @game.takeover_swap_range(takeover[:acquirer], takeover[:target], pending_holder_index, takeover[:swaps].sum)
          end

          def cash_for(shares, swapped)
            @game.format_currency((shares - swapped) * takeover[:target].share_price.price)
          end

          def consenter
            @game.takeover_consenter(takeover[:acquirer], takeover[:target])
          end

          def awaiting_consent?
            !!takeover && !takeover[:consented] && !!consenter
          end

          def advance_takeover!
            return if awaiting_consent?

            while pending_holder_index && (range = swap_range).min == range.max
              takeover[:swaps] << range.min
            end
            return if pending_holder_index

            @game.take_over!(takeover[:acquirer], takeover[:target], takeover[:swaps])
            @round.takeover = nil
          end
        end
      end
    end
  end
end
