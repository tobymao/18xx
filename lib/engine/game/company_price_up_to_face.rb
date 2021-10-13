# frozen_string_literal: true

#
# This module can be called from setup method
# in the Engine::Game class for the game to
# modify the allowed price for purchasing companies
# to between 1 to face value

module CompanyPriceUpToFace
  def setup_company_price_up_to_face
    @companies.each do |company|
      company.min_price = 1
      company.max_price = company.value
    end
  end
end
