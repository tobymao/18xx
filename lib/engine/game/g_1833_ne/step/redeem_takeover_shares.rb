# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'takeover_offer'

module Engine
  module Game
    module G1833NE
      module Step
        class RedeemTakeoverShares < Engine::Step::Base
          include TakeoverOffer

          ACTIONS = %w[choose].freeze

          def actions(entity)
            return [] unless entity == current_entity

            ACTIONS
          end

          def active?
            !!pending_holder_index
          end

          def active_entities
            [takeover[:acquirer]]
          end

          def description
            "Redeem #{takeover[:target].name} shares"
          end

          def choice_name
            holder, shares = holdings[pending_holder_index]
            "#{holder.name}'s #{shares} #{takeover[:target].name} share(s): "\
              "how many to redeem with #{takeover[:acquirer].name} shares, the rest for cash"
          end

          def choices
            shares = holdings[pending_holder_index].last
            swap_range.to_h { |swapped| [swapped.to_s, "#{swapped} share(s) + #{cash_for(shares, swapped)}"] }
          end

          def process_choose(action)
            swapped = action.choice.to_i
            raise GameError, 'Invalid number of shares to redeem' unless swap_range.include?(swapped)

            takeover[:swaps] << swapped
            advance_takeover!
          end
        end
      end
    end
  end
end
