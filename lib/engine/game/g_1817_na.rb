# frozen_string_literal: true

require_relative 'g_1817'
require_relative '../config/game/g_1817_na'

module Engine
  module Game
    class G1817NA < G1817
      load_from_json(Config::Game::G1817NA::JSON)

      DEV_STAGE = :alpha
      GAME_PUBLISHER = nil
      PITTSBURGH_PRIVATE_NAME = 'DTC'
      PITTSBURGH_PRIVATE_HEX = 'F14'

      GAME_LOCATION = 'North America'
      SEED_MONEY = 150
      GAME_RULES_URL = {
        '1817NA' => 'https://docs.google.com/document/d/1b1qmHoyLnzBo8SRV8Ff17iDWnB7UWNbIsOyDADT0-zY/view',
        '1817 Rules' => 'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view',
      }.freeze
      GAME_DESIGNER = 'Mark Voyer'

      def self.title
        '1817NA'
      end

      # Not genericifying 1817's loan logic just so it can be kept simpler, at least for now
      def init_loans
        @loan_value = 100
        56.times.map { |id| Loan.new(id, @loan_value) }
      end

      def future_interest_rate
        [[5, ((loans_taken + 3) / 4).to_i * 5].max, 70].min
      end

      def interest_change
        rate = future_interest_rate
        summary = []
        unless rate == 5
          loans = ((loans_taken - 1) % 4) + 1
          s = loans == 1 ? '' : 's'
          summary << ["Interest if #{loans} more loan#{s} repaid", rate - 5]
        end
        if loans_taken.zero?
          summary << ['Interest if 5 more loans taken', 10]
        elsif rate != 70
          loans = 5 - ((loans_taken + 4) % 4)
          s = loans == 1 ? '' : 's'
          summary << ["Interest if #{loans} more loan#{s} taken", rate + 5]
        end
        summary
      end
    end
  end
end
