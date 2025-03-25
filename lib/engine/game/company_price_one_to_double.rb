# frozen_string_literal: true

#
# This module can be called from setup method
# in the Engine::Game class for the game to
# modify the allowed price for purchasing companies
# to between $1 and twice the face value.
#
# This is used in e.g 1844
#
module CompanyPriceOneToDouble
  def setup_company_price_one_to_double
    @companies.each do |company|
      company.min_price = 1
      company.max_price = company.value * 2
    end
  end
end
