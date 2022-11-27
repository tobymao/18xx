# frozen_string_literal: true

module View
  module ShareCalculation
    def num_shares_of(entity, corporation)
      return corporation.president?(entity) ? 1 : 0 if corporation.minor?

      entity.num_shares_of(corporation, ceil: false)
    end

    def percentage_of(entity, corporation)
      return corporation.president?(entity) ? 100 : 0 if corporation.minor?

      entity.percent_of(corporation)
    end
  end
end
