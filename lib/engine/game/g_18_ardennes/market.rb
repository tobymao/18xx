# frozen_string_literal: true

module Engine
  module Game
    module G18Ardennes
      module Market
        CURRENCY_FORMAT_STR = '%d F'
        BANK_CASH = 12_000
        STARTING_CASH = { 3 => 700, 4 => 525, 5 => 420 }.freeze
        SOLD_OUT_INCREASE = false
        POOL_SHARE_DROP = :down_block

        # The certificate limit varies according to the number of 10-share
        # companies operating.
        CERT_LIMIT = {
          3 => { 0 => 11, 1 => 11, 2 => 12, 3 => 13, 4 => 14, 5 => 15, 6 => 15 },
          4 => { 0 => 8, 1 => 8, 2 => 9, 3 => 10, 4 => 11, 5 => 12, 6 => 12 },
          5 => { 0 => 6, 1 => 6, 2 => 7, 3 => 8, 4 => 9, 5 => 10, 6 => 10 },
        }.freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          par_1: :red,
          par_2: :blue,
        ).freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par_1: 'Minor company starting values',
          par_2: 'Major company starting values',
          repar: 'Minor companies cannot merge'
        )
        MARKET = [%w[0r 50x 55x 60x 70x 80x 90x 100 110 120 140z 160z 180z 200z 220z 240 260 280 300 320 340 360 380 400]].freeze

        # Minors in the left-hand most space do not count against cert limit.
        CERT_LIMIT_TYPES = [:repar].freeze

        def ipo_name(_entity)
          'Treasury'
        end

        def init_cert_limit
          players = @players.size
          big_companies = @corporations.count { |c| c.type == :'10-share' }
          @cert_limit = game_cert_limit[players][big_companies]
        end
      end
    end
  end
end
