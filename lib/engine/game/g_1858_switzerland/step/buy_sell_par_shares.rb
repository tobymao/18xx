# frozen_string_literal: true

require_relative '../../g_1858/step/buy_sell_par_shares'

module Engine
  module Game
    module G1858Switzerland
      module Step
        class BuySellParShares < G1858::Step::BuySellParShares
          ROBOT_ACTIONS = %w[buy_company].freeze

          def actions(entity)
            return super unless entity == @game.robot
            return [] if @acted
            return [] unless priciest_company

            ROBOT_ACTIONS
          end

          def auto_actions(entity)
            return super unless entity == @game.robot
            return [] unless (company = priciest_company)

            [Engine::Action::BuyCompany.new(entity, company: company, price: 0)]
          end

          def process_buy_company(action)
            player = action.entity
            company = action.company
            owner = company.owner

            raise GameError, "Cannot buy #{company.name} from #{owner.name}" unless owner == @game.bank
            raise GameError, "Only #{@game.robot.name} can buy a private railway company." unless player == @game.robot

            @log << "#{player.name} acquires #{company.name} from #{owner.name}."
            @game.purchase_company(player, company, action.price)
            track_action(action, company)
          end

          private

          # Finds the most expensive private railway company currently
          # available. If there are two at the same price then the first in
          # company order is returned. Nil is returned if there are no
          # companies available.
          def priciest_company
            companies = @game.buyable_bank_owned_companies
            max_value = companies.map(&:value).max
            companies.find { |c| c.value == max_value }
          end
        end
      end
    end
  end
end
