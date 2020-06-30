# frozen_string_literal: true

module Engine
  module Step
    module PayoutCompanies
      def payout_companies
        @game.companies.select(&:owner).each do |company|
          next unless (revenue = company.revenue).positive?

          owner = company.owner
          @game.bank.spend(revenue, owner)
          @log << "#{owner.name} collects #{@game.format_currency(revenue)} from #{company.name}"
        end
      end
    end
  end
end
