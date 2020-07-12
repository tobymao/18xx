# frozen_string_literal: true

#
# This module sets up so that the allowed price
# for purchasing private companies are between
# 50% and 150% of the face value.
# This is used in e.g 18MEX and 18AL.
#
module CompanyPrice50To150Percent
  def setup
    @companies.each do |company|
      company.min_price = company.value * 0.5
      company.max_price = company.value * 1.5
    end
  end
end
