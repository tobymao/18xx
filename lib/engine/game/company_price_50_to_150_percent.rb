# frozen_string_literal: true

#
# This module can be called from setup method
# in the Engine::Game class for the game to
# modify the allowed price for purchasing companies
# to between 50% and 150% of the face value.
#
# This is used in e.g 18MEX and 18AL.
#
module CompanyPrice50To150Percent
  def setup_company_price_50_to_150_percent
    @companies.each do |company|
      company.min_price = company.value * 0.5
      company.max_price = company.value * 1.5
    end
  end
end
