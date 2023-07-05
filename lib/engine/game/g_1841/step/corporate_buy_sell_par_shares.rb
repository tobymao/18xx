# frozen_string_literal: true

require_relative 'buy_sell_par_shares'

module Engine
  module Game
    module G1841
      module Step
        class CorporateBuySellParShares < BuySellParShares
          def description
            'Corporate Sell then Buy Shares'
          end

          def pass_description
            if @round.current_actions.empty?
              'Pass (Corporate Share)'
            else
              'Done (Corporate Share)'
            end
          end

          # FIXME
          def must_sell?(_entity)
            nil
          end

          def can_sell_any?(entity)
            entity.corporate_shares.select { |share| can_sell?(entity, share.to_bundle) }.any? ||
              entity.ipo_shares.select { |share| can_sell?(entity, share.to_bundle) }.any?
          end

          def can_buy_any_from_market?(entity)
            @game.share_pool.shares.any? { |s| can_buy?(entity, s.to_bundle) }
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed
              return true if corporation.shares.any? { |s| can_buy?(entity, s.to_bundle) }
            end

            false
          end

          def can_buy?(entity, bundle)
            return unless bundle
            return if entity == bundle.corporation

            super
          end

          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity

            corporation = bundle.corporation

            # can't buy controlling corp
            !@game.in_chain?(entity, corporation) &&
              # can't allow buyer to have more than 5 certs of a given corporation
              (@game.num_certs(entity) < @game.cert_limit(entity)) &&
              # can't allow player to control too much
              ((@game.player_controlled_percentage(entity,
                                                   corporation) + bundle.common_percent) <= corporation.max_ownership_percent)
          end
        end
      end
    end
  end
end
