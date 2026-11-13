# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1835
      class SharePool < Engine::SharePool
        def possible_reorder(shares)
          # unless we're swapping, return the big shares first, so that we do not get stuck in case the new president
          # has small shares that would not add up to the president share's percentage.
          # Example: President's share as 20%, new president has 10, 20, 20. Sorting ascending yields 10 first, which is not
          # enough, take the 20 as well and we overshoot. Hence, we sort descending.
          return shares.sort_by(&:percent).reverse if @game.round.swap_choice_player.nil?
          return shares.sort_by(&:percent).reverse if @game.round.swap_for_higher_percentage

          shares.sort_by(&:percent)
        end

        def change_president(presidents_share, swap_to, president, previous_president)
          president_percent = presidents_share.percent
          presidents_percentages = president.shares_of(presidents_share.corporation).map(&:percent)
          choice_available = presidents_percentages.count(president_percent / 2) >= 2 &&
                             presidents_percentages.count(president_percent) >= 1
          if @game.round.swap_choice_player.nil? && choice_available
            @game.round.swap_presidents_share = presidents_share
            @game.round.swap_choice_player = previous_president
            @game.round.swap_location = swap_to
            @game.round.swap_other_player = president
            return
          end

          super
        end
      end
    end
  end
end
