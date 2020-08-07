# frozen_string_literal: true

require_relative '../config/game/g_18_ms'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18MS < Base
      load_from_json(Config::Game::G18MS::JSON)

      GAME_LOCATION = 'Mississippi, USA'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]

      # Game ends after 5 * 2 ORs
      GAME_END_CHECK = { final_or_set: 5 }.freeze

      HOME_TOKEN_TIMING = :operating_round

      #      def init_round
      #        Round::G18MS::Draft.new(@players.reverse, game: self)
      #      end

      include CompanyPrice50To150Percent

      def setup
        setup_company_price_50_to_150_percent
      end

      def new_operating_round(round_num = 1)
        # Switch to phase 3 if OR1.2 is to start
        @phase.next! if @turn == 1 && round_num == 2
        super
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::SpecialBuyTrain,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def or_set_finished
        case @turn
        when 3 then rust('2+', 20)
        when 4 then rust('3+', 30)
        when 5 then rust('4+', 60)
        end
      end

      private

      def rust(train, salvage_value)
        rusted_trains = []
        trains.each do |t|
          next if t.rusted || t.name != train

          rusted_trains << t.name
          @bank.spend(salvage_value, t.owner)
          t.rust!
        end

        return unless rusted_trains.any?

        @log << "-- Event: #{rusted_trains.uniq.join(', ')} trains rust --"
        @log << "Corporations received a salvage value of #{format_currency(salvage_value)} per rusted train"
      end
    end
  end
end
