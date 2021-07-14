# frozen_string_literal: true

module View
  module ShareCalculation
    def num_shares_of(entity, corporation)
      return corporation.president?(entity) ? 1 : 0 if corporation.minor?

      entity.num_shares_of(corporation, ceil: false)
    end
  end
end
