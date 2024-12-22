# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/share_buying'

module Engine
  module Game
    module G18FR
      module Step
        class RedeemShares < G18FR::Step::BuySellParShares
          def actions(entity)
            puts 'dupa'
            return [] if !entity.corporation? || entity != current_entity
            puts entity.name
            available_actions = []

            available_actions << 'take_loan' if @game.can_take_loan?(entity) && !@corporate_action.is_a?(Action::BuyShares)
            puts '1'
            available_actions << 'buy_shares' unless @game.redeemable_shares(entity).empty?
            puts '2'
            available_actions << 'pass' if available_actions.any?
            puts '3'
            puts available_actions
            puts '4'

            if available_actions.empty?
              puts 'empty'
              log_skip(entity)
              @round.next_entity!
            end

            available_actions
          end

          def pass_description
            'Pass'
          end

          def log_pass(entity)
            @log << "#{entity.name} passes in Share Redemption Round"
          end

          def process_pass(action)
            log_pass(action.entity)
            @round.next_entity!
          end

          def log_skip(entity)
            @log << "#{entity.name} doesn't have any shares in the Market and skips President's Choice round"
          end
        end
      end
    end
  end
end
