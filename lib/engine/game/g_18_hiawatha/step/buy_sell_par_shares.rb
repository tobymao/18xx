# frozen_string_literal: true

module Engine
  module Game
    module G18Hiawatha
      module Step
        class BuySellParShares < G1817::Step::BuySellParShares
          def use_on_assign_abilities(company)
            corporation = company.owner
            case company.id
            when 'US'
              corporation.tokens << Engine::Token.new(corporation)
              ability.additional_token.use!
              @log << "#{corporation.name} acquires additonal token from #{company.name}"
            when 'RR'
              @game.assign_rr_train(company, corporation)
            when 'JLBC'
              @game.assign_jlbc_home_hex(company, corporation)
            when 'PC'
              company.revenue = 20
              @log << "#{company.name} assigned to #{corporation.name}. #{company.name} revenue increased to $20 per OR."
            end
          end
        end
      end
    end
  end
end
