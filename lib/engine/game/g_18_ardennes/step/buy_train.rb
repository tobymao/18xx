# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18Ardennes
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.receivership?

            actions = super
            actions << 'sell_company' if actions.include?('sell_shares') &&
                                         can_sell_any_companies?(entity)
            actions
          end

          def train_variant_helper(train, entity)
            return super if @game.can_buy_4d?(entity)

            super.reject { |v| v[:name] == '4D' }
          end

          def process_sell_company(action)
            player = action.entity
            company = action.company
            price = company.value
            company.owner = @game.bank
            player.companies.delete(company)
            @game.bank.spend(price, player)
            @log << "#{player.name} sells #{company.name} to bank for #{@game.format_currency(price)}"
          end

          def log_skip(entity)
            super unless entity.receivership?
          end

          private

          def can_sell_any_companies?(entity)
            player = entity.owner
            return false unless player&.player?

            !player.companies.select { |c| c.type == :minor }.empty?
          end
        end
      end
    end
  end
end
