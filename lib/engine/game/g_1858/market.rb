# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Market
        CURRENCY_FORMAT_STR = 'Pt%d'
        BANK_CASH = { 2 => 8_000, 3 => 12_000, 4 => 12_000, 5 => 12_000, 6 => 12_000 }.freeze
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = true
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        SELL_MOVEMENT = :left_block_pres
        SOLD_OUT_INCREASE = false
        MARKET_SHARE_LIMIT = 50
        CERT_LIMIT = { 2 => 21, 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze
        STARTING_CASH = { 2 => 500, 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze

        MARKET = [%w[0c 50 60 65 70p 80p 90p 100p 110p 120p 135p 150p 165 180 200 220 245 270 300]].freeze

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def can_hold_above_corp_limit?(_entity)
          true
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] if entity.num_ipo_shares.zero?

          bundles_for_corporation(entity, entity).select { |bundle| @share_pool.fit_in_bank?(bundle) }
        end

        def emergency_issuable_bundles(entity)
          return [] unless entity.trains.empty?
          return [] if entity.cash >= @depot.max_depot_price

          eligible, remaining = issuable_shares(entity)
            .partition { |bundle| bundle.price + entity.cash < @depot.max_depot_price }
          eligible.concat(remaining.take(1))
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(share_pool, entity).reject { |bundle| entity.cash < bundle.price }
        end
      end
    end
  end
end
