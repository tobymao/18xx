# frozen_string_literal: true

require_relative '../../g_1817/step/buy_sell_par_shares'

module Engine
  module Game
    module G18Hiawatha
      module Step
        class BuySellParShares < G1817::Step::BuySellParShares
          def use_on_assign_abilities(company)
            corporation = company.owner

            @game.abilities(company, :additional_token) do |ability|
              corporation.tokens << Engine::Token.new(corporation)
              ability.use!
              @log << "#{corporation.name} acquires additonal token from #{company.name}"
            end
            case company.id
            when 'RR'
              @game.assign_rr_train(company, corporation)
            when 'JLBC'
              @game.assign_jlbc_home_hex(company, corporation)
            when 'PC'
              company.revenue = 20
              @log << "#{company.name} assigned to #{corporation.name}. #{company.name} revenue increased to $20 per OR."
            end
          end

          def can_short?(entity, corporation)
            shorts = @game.shorts(corporation).size

            corporation.floated? &&
              shorts < corporation.total_shares &&
              entity.num_shares_of(corporation) <= 0 &&
              !(corporation.share_price.acquisition? || corporation.share_price.liquidation?) &&
              !@round.players_sold[entity].value?(:short)
          end
        end
      end
    end
  end
end
