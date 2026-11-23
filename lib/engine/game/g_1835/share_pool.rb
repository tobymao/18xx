# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1835
      class SharePool < Engine::SharePool
        NUMBERS_AS_WORDS = %w[zero one two three four five].freeze

        def possible_reorder(shares)
          # unless we're swapping, return the big shares first, so that we do not get stuck in case the new president
          # has small shares that would not add up to the president share's percentage.
          # Example: President's share as 20%, new president has 10, 20, 20. Sorting ascending yields 10 first, which is not
          # enough, take the 20 as well and we overshoot. Hence, we sort descending.
          return shares.sort_by(&:percent).reverse if @game.round.swap_choice_player.nil?
          return shares.sort_by(&:percent).reverse if @game.round.swap_for_higher_percentage

          shares.sort_by(&:percent)
        end

        def change_president(presidents_share, _, president, previous_president)
          swap_to = presidents_share.owner.player? ? previous_president : self
          president_percent = presidents_share.percent
          presidents_percentages = president.shares_of(presidents_share.corporation).map(&:percent)
          choice_available = presidents_percentages.count(president_percent / 2) >= 2 &&
                             presidents_percentages.count(president_percent) >= 1 &&
            presidents_share.owner.player?

          if @game.round.swap_choice_player.nil? && choice_available
            @game.round.swap_presidents_share = presidents_share
            @game.round.swap_choice_player = previous_president
            @game.round.swap_location = swap_to
            @game.round.swap_other_player = president
            return
          end

          super(presidents_share, swap_to, president, previous_president)
        end

        def num_presentation(bundle)
          return "a #{bundle.percent}% share" if bundle.shares.size == 1
          return "#{bundle.shares.size} #{bundle.shares.first.percent}% shares" if bundle.shares.map(&:percent).uniq.size == 1

          low, high = bundle.shares.map(&:percent).tally.sort_by { |p, _| p }

          number_to_word = ->(i) { NUMBERS_AS_WORDS[i] || ('' + i) }

          "#{number_to_word.call(low[1])} #{low[0]}% and #{number_to_word.call(high[1])} #{high[0]}% share(s)"
        end
      end
    end
  end
end
