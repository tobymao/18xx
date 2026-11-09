# frozen_string_literal: true

require_relative '../../../step/buy_company'
require_relative 'skip_for_national'

module Engine
  module Game
    module G18Cuba
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          include SkipForNational
        end
      end
    end
  end
end
