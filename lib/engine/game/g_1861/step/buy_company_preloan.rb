# frozen_string_literal: true

require_relative '../../g_1867/step/buy_company_preloan'
require_relative 'skip_for_national'

module Engine
  module Game
    module G1861
      module Step
        class BuyCompanyPreloan < G1867::Step::BuyCompanyPreloan
          include SkipForNational
        end
      end
    end
  end
end
