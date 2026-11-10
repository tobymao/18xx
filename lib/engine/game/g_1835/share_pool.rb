# frozen_string_literal: true

require_relative '../../share_pool'

module Engine
  module Game
    module G1835
      class SharePool < Engine::SharePool
        # Bring higher percent shares to the front in order to always exchange the correct total percentage when the president
        # of PR changes. Otherwise, one 5% share might get exchanged for the 10% director share.
        def possible_reorder(shares)
          shares.sort_by(&:percent).reverse
        end

        # overridden, because the usual logic of picking shares using num_shares does not work with varying percentages
        def change_president(presidents_share, swap_to, president, previous_president)
          corporation = presidents_share.corporation

          president_percent = presidents_share.percent

          shares_to_swap_to_old_president = shares_for_presidency_swap(president_percent,
                                                                       possible_reorder(president.shares_of(corporation)))

          shares_to_swap_to_old_president.each do |s|
            move_share(s, swap_to)
          end
          move_share(presidents_share, president)

          return unless previous_president.shares_of(corporation).map(&:percent).any? { |p| p == president_percent }
          return unless president.shares_of(corporation).map(&:percent).count { |p| p == president_percent / 2 } >= 2

          @game.round.swap_choice_player = previous_president
          @game.round.swap_location = swap_to
          @game.round.swap_other_player = president
          @game.round.swap_corporation = corporation
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

        private

        def shares_for_presidency_swap(president_percent, shares_of_current_president)
          shares_to_swap_to_old_president = []
          shares_of_current_president.each do |share|
            break if shares_to_swap_to_old_president.sum(&:percent) >= president_percent

            shares_to_swap_to_old_president << share
          end

          if shares_to_swap_to_old_president.sum(&:percent) != president_percent
            raise GameError,
                  "Could not find shares that sum up to the president share's percentage (#{president_percent}%)"
          end

          shares_to_swap_to_old_president
        end
      end
    end
  end
end
