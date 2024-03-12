# frozen_string_literal: true

require_relative '../../../step/exchange'

module Engine
  module Game
    module G18Neb
      module Step
        class Exchange < Engine::Step::Exchange
          def process_buy_shares(action)
            bundle = action.bundle
            corporation = bundle.corporation
            treasury_share = bundle.owner == corporation
            super
            return unless treasury_share

            @game.bank.spend(corporation.share_price.price, corporation)
            @log << "#{corporation.name} receives #{@game.format_currency(corporation.share_price.price)} from the bank"
          end
        end
      end
    end
  end
end
