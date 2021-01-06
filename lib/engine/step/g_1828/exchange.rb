# frozen_string_literal: true

require_relative '../base'
require_relative '../exchange'
require_relative 'buy_sell_par_shares'

module Engine
  module Step
    module G1828
      class Exchange < Exchange
        def process_buy_shares(action)
          super
          @round.steps.find { |s| s.is_a?(Engine::Step::G1828::BuySellParShares) }.stock_action(action)
        end
      end
    end
  end
end
