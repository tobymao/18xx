# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18CO
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def get_par_prices(_entity, corp)
            @game.par_prices(corp)
          end

          def process_par(action)
            super(action)

            @game.par_change_float_percent(action.corporation)
          end

          def purchasable_companies(entity = nil)
            companies = super

            companies.select(&:owner)
          end

          def can_buy_any_from_ipo?(entity)
            @game.corporations.each do |corporation|
              next unless corporation.ipoed

              corporation.shares.group_by(&:corporation).each do |_, shares|
                return true if can_buy_shares?(entity, shares)
              end
            end

            false
          end

          def can_buy?(entity, bundle)
            if bundle&.owner&.corporation? && bundle.corporation != bundle.owner &&
                @game.presidents_choice != :done && !bundle.owner.president?(entity)
              return false
            end

            super
          end

          def swap_sell(player, corporation, bundle, pool_share)
            return if pool_share.percent != corporation.share_percent
            return if bundle.percent == pool_share.percent
            return unless bundle.shares.find { |s| s.percent != corporation.share_percent && !s.president }

            can_sell?(player, bundle_reduced_percent(bundle.shares)) ? pool_share : nil
          end

          private

          def bundle_reduced_percent(shares)
            # Dup is needed to avoid affecting the actual percentage in the original bundle
            updated_bundle = Engine::ShareBundle.new(shares.map(&:dup))
            updated_bundle.shares.first.percent -= shares.first.corporation.share_percent
            updated_bundle
          end
        end
      end
    end
  end
end
