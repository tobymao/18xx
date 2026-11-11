# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1835
      class SharePool < Engine::SharePool
        def change_president(presidents_share, swap_to, president, previous_president)
          corporation = presidents_share.corporation
          president_percent = presidents_share.percent
          presidents_percentages = president.shares_of(corporation).map(&:percent)
          if presidents_percentages.count(president_percent / 2) >= 2 && presidents_percentages.count(president_percent) >= 1
            @game.round.swap_choice_player = previous_president
            @game.round.swap_location = swap_to
            @game.round.swap_other_player = president
            @game.round.swap_corporation = corporation
            swap_possible = true
          end

          super

          return unless swap_possible

          @game.log << "Presidency swapped for cert of #{president_percent}% by default.
                          #{swap_to.name} may choose to swap for two shares of #{president_percent / 2}% instead."
        end

        def swap(from, to, corporation, percent_to_swap_for)
          percent_per_share = percent_to_swap_for / 2
          double = from.shares_of(corporation).find { |share| share.percent == percent_to_swap_for }
          move_share(double, to)
          shares = to.shares_of(corporation).select { |s| s.percent == percent_per_share }.take(2)
          shares.each { |s| move_share(s, from) }
        end
      end
    end
  end
end
