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

          def can_buy?(entity, bundle)
            return unless bundle
            return unless bundle.buyable
            return if bundle.owner.corporation? && bundle.owner != bundle.corporation

            super
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity

            corporation = bundle.corporation

            # can't exceed cert limit
            (!corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit(entity)) &&
              # can't allow player to control too much
              ((@game.player_controlled_percentage(entity,
                                                   corporation) + bundle.common_percent) <= corporation.max_ownership_percent)
          end

          def pass!
            super
            post_share_pass_step! if @round.corp_started
          end

          def log_pass(entity)
            return super unless @round.corp_started

            @log << "#{entity.name} declines to purchase additional shares of #{@round.corp_started.name}"
          end

          def sell_shares(entity, shares, swap: nil)
            old_frozen = @game.frozen_corporations
            super
            @game.update_frozen!
            return if @game.frozen_corporations.none? { |c| !old_frozen.include?(c) }

            raise GameError, 'Cannot sell if it causes a circular chain of ownership'
          end

          def process_buy_shares(action)
            super
            @game.update_frozen!
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
