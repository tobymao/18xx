# frozen_string_literal: true

require_relative '../buy_company'
require_relative 'skip_for_national'

module Engine
  module Step
    module G1861
      class BuyCompany < BuyCompany
        include SkipForNational
      end
    end
  end
end
