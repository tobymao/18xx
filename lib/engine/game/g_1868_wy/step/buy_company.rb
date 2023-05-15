# frozen_string_literal: true

require_relative '../../../step/buy_company'
require_relative '../skip_coal_and_oil'

module Engine
  module Game
    module G1868WY
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          include G1868WY::SkipCoalAndOil

          def can_buy_company?(entity)
            @game.skip_homeless_dpr?(entity) ? false : super
          end

          def pay(entity, owner, price, company)
            entity.spend(price, owner || @game.bank, check_positive: @game.phase.name != '2')

            @game.company_bought(company, entity)

            @log << "#{entity.name} buys #{company.name} from "\
                    "#{owner.name} for #{@game.format_currency(price)}"
          end
        end
      end
    end
  end
end
