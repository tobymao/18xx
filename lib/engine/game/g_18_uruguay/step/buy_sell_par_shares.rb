# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Uruguay
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def visible_corporations
            return @game.corporations.reject { |c| c == @game.fce } if !@game.nationalized? && !@game.nationalization_triggered

            @game.corporations
          end

          def holding_ok?(corporation, entity, bundle)
            if corporation.president?(entity) && (corporation.loans.size > corporation.num_player_shares)
              return corporation.ipo_shares.first.id != bundle.shares.first.id
            end

            corporation.holding_ok?(entity, bundle.common_percent)
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            return false if bundle.owner.player? &&
                            !@game.class::BUY_SHARE_FROM_OTHER_PLAYER &&
                            (!@game.class::CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT || !entity.corporation?)

            corporation = bundle.corporation

            holding_ok?(corporation, entity, bundle) &&
              (!corporation.counts_for_limit || exchange || @game.num_certs(entity) < @game.cert_limit(entity))
          end
        end
      end
    end
  end
end
