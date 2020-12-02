# frozen_string_literal: true

require_relative 'g_1817'
require_relative '../config/game/g_1817_wo'

module Engine
  module Game
    class G1817WO < G1817
      load_from_json(Config::Game::G1817WO::JSON)

      DEV_STAGE = :prealpha
      GAME_PUBLISHER = nil
      PITTSBURGH_PRIVATE_NAME = 'PSM'
      PITTSBURGH_PRIVATE_HEX = 'I6'

      GAME_LOCATION = 'Earth.'
      SEED_MONEY = 100
      GAME_RULES_URL = {
        '1817WO' => 'https://docs.google.com/document/d/1g9QnttpJa8yOCOTnfPaU9hfAZFFzg-rAs_WGy9T38J0/',
        '1817 Rules' => 'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view',
      }.freeze
      GAME_DESIGNER = 'Mark Voyer & Brennan Sheremeto'

      def self.title
        '1817WO'
      end

      # Not genericifying 1817's loan logic just so it can be kept simpler, at least for now
      def init_loans
        @loan_value = 100
        39.times.map { |id| Loan.new(id, @loan_value) }
      end

      def future_interest_rate
        [[5, ((loans_taken + 2) / 3).to_i * 5].max, 65].min
      end

      def interest_change
        rate = future_interest_rate
        summary = []
        unless rate == 5
          loans = ((loans_taken - 1) % 3) + 1
          s = loans == 1 ? '' : 's'
          summary << ["Interest if #{loans} more loan#{s} repaid", rate - 5]
        end
        if loans_taken.zero?
          summary << ['Interest if 4 more loans taken', 10]
        elsif rate != 65
          loans = 3 - ((loans_taken + 2) % 3) # Is this right?
          s = loans == 1 ? '' : 's'
          summary << ["Interest if #{loans} more loan#{s} taken", rate + 5]
        end
        summary
      end
    end
  end
end
