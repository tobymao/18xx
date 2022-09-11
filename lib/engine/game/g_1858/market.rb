# frozen_string_literal: true

module Engine
  module Game
    module G1858
      module Market
        CURRENCY_FORMAT_STR = 'Pt%d'
        BANK_CASH = 12_000
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = true
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        SELL_MOVEMENT = :left_block
        MARKET_SHARE_LIMIT = 50
        CERT_LIMIT = { 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze
        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 300, 6 => 250 }.freeze

        MARKET = [%w[0c 50 60 65 70p 80p 90p 100p 110p 120p 135p 150p 165 180 200 220 245 270 300]].freeze

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def issuable_shares(entity)
          return [] unless entity.corporation?
          return [] if entity.num_ipo_shares.zero?

          bundles_for_corporation(entity, entity).select { |bundle| @share_pool.fit_in_bank?(bundle) }
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(share_pool, entity).reject { |bundle| entity.cash < bundle.price }
        end
      end
    end
  end
end
