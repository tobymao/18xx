# frozen_string_literal: true

require_relative '../config/game/g_1877'
require_relative 'g_1817'

module Engine
  module Game
    class G1877 < G1817
      load_from_json(Config::Game::G1877::JSON)

      GAME_DESIGNER = 'Scott Petersen & Toby Mao'
      GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1877'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1877'
      GAME_PUBLISHER = :all_aboard_games
      GAME_LOCATION = 'Venezuela'

      DISCARDED_TRAINS = :remove

      OPTIONAL_RULES = [
        {
          sym: :cross_train,
          short_name: 'Cross Train Purchases',
          desc: 'Allows corporations to purchase trains from others',
        },
      ].freeze

      DEV_STAGE = :alpha

      SELL_AFTER = :any_time

      EVENTS_TEXT = Base::EVENTS_TEXT.merge('signal_end_game' => ['Signal End Game',
                                                                  'Game Ends 3 ORs after purchase/export'\
                                                                  ' of first 4 train']).freeze
      def event_signal_end_game!
        @final_operating_rounds = 2
        game_end_check
        @final_turn -= 1 if @round.stock?
        @log << "First 4 train bought/exported, ending game at the end of #{@final_turn}.#{@final_operating_rounds}"
      end

      def size_corporation(corporation, size)
        corporation.second_share = nil

        if size == 10
          original_shares = @_shares.values.select { |share| share.corporation == corporation }

          corporation.share_holders.clear
          shares = 5.times.map { |i| Share.new(corporation, percent: 10, index: i + 1) }

          original_shares.each do |share|
            share.percent = share.president ? 20 : 10
            corporation.share_holders[share.owner] += share.percent
          end

          shares.each do |share|
            add_new_share(share)
          end
        end

        @log << "#{corporation.name} floats and transfers 60% to the market"
        corporation.spend(corporation.cash, @bank)
        @bank.spend(((corporation.par_price.price * corporation.total_shares) / 2).floor, corporation)

        total = 0
        shares = corporation.shares.take_while { |share| (total += share.percent) <= 60 }
        @share_pool.transfer_shares(ShareBundle.new(shares), @share_pool)
      end

      def float_corporation(corporation); end

      def buy_train(operator, train, price = nil)
        super
        train.buyable = false unless @optional_rules&.include?(:cross_train)
      end

      private

      def init_round
        stock_round
      end

      def stock_round
        close_bank_shorts
        @interest_fixed = nil

        Round::G1817::Stock.new(self, [
          Step::DiscardTrain,
          Step::HomeToken,
          Step::G1877::BuySellParShares,
        ])
      end
    end
  end
end
