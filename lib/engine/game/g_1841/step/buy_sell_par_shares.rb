# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative '../../../step/share_buying'
require_relative '../../../action/buy_shares'
require_relative '../../../action/par'
require_relative 'corp_start'

module Engine
  module Game
    module G1841
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include CorpStart
          def description
            'Sell then Buy Shares or Concessions'
          end

          def round_state
            super.merge({ corp_started: nil })
          end

          def setup
            super
            @round.corp_started = nil
          end

          # FIXME
          def purchasable_companies(_entity)
            []
          end

          # FIXME
          def buyable_bank_owned_companies(_entity)
            []
          end

          def can_buy_multiple?(entity, corporation, _owner)
            @round.current_actions.any? { |x| x.is_a?(Action::Par) && x.corporation == corporation } &&
              entity.percent_of(corporation) < 40
          end

          def pass!
            super
            post_share_pass_step! if @round.corp_started
          end

          def log_pass(entity)
            return super unless @round.corp_started

            @log << "#{entity.name} declines to purchase additional shares of #{@round.corp_started.name}"
          end

          def process_par(action)
            @round.corp_started = action.corporation
            super
          end
        end
      end
    end
  end
end
