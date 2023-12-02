# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1847AE
      module Round
        class Stock < Engine::Round::Stock
          def setup
            @game.exchange_all_investor_companies! if @game.must_exchange_investor_companies
            @game.nationalization_actions_this_round = []

            super
          end
        end
      end
    end
  end
end
