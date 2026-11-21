# frozen_string_literal: true

require_relative '../../../step/buy_company'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1833NE
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          include ReceivershipSkip

          def process_buy_company(action)
            super

            @game.activate_lowell_merchants_company! if action.company.id == 'P2'
          end

          def pay(entity, owner, price, company)
            return super unless company.id == @game.class::DH_COMPANY

            fee = @game.class::DH_PURCHASE_FEE
            if entity.cash < price + fee
              raise GameError, "#{entity.name} needs #{@game.format_currency(price + fee)} to buy #{company.name} "\
                               "(#{@game.format_currency(price)} plus a #{@game.format_currency(fee)} fee to the bank)"
            end

            super
            entity.spend(fee, @game.bank)
            @log << "#{entity.name} pays a #{@game.format_currency(fee)} fee to the bank"
          end
        end
      end
    end
  end
end
