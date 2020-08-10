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

      COMPANY_1_AND_2 = %w[AGS BS].freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_companies_operation_round_one' =>
          ['Can Buy Companies OR 1', 'Corporations can buy AGS/BS companies for face value in OR 1'],
      ).freeze

      #      def init_round
      #        Round::G18MS::Draft.new(@players.reverse, game: self)
      #      end

      include CompanyPrice50To150Percent

      def purchasable_companies
        companies = super
        return companies unless @phase.status.include?('can_buy_companies_operation_round_one')

        return [] if @turn > 1

        companies.select do |company|
          COMPANY_1_AND_2.include?(company.id)
        end
      end

      def new_operating_round(round_num = 1)
        # For OR 1, set company buy price to face value only
        @companies.each do |company|
          company.min_price = company.value
          company.max_price = company.value
        end if @turn == 1

        # After OR 1, the company buy price is changed to 50%-150%
        setup_company_price_50_to_150_percent if @turn == 2 && round_num == 1

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
          Step::G18MS::BuyCompany,
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
