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
            entity = action.entity
            company = action.company
            fee = company.id == @game.class::DH_COMPANY ? @game.class::DH_PURCHASE_FEE : 0
            if fee.positive? && entity.cash < action.price + fee
              raise GameError, "#{entity.name} cannot afford the price plus the #{@game.format_currency(fee)} fee"
            end

            super

            if fee.positive?
              entity.spend(fee, @game.bank)
              @log << "#{entity.name} pays a #{@game.format_currency(fee)} fee to the bank"
            end
            @game.activate_lowell_merchants_company! if company.id == 'P2'
            @game.clear_graph_for_entity(entity) if @game.class::OFFBOARD_TOKEN_COMPANIES.key?(company.id)
          end
        end
      end
    end
  end
end
