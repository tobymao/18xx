# frozen_string_literal: true

module Engine
  module Game
    module G1841
      module Step
        module EmergencyAssist
          def sweep_cash(entity, seller, cost)
            return if entity == seller

            @game.chain_of_control(entity).each do |controller|
              needed = [cost - entity.cash, 0].max
              amount = [needed, controller.cash].min
              if amount.positive?
                @log << "Sweeping #{@game.format_currency(amount)} from #{controller.name} to #{entity.name} (EMR)"
                controller.spend(amount, entity)
              end
              break if controller == seller
            end
          end
        end
      end
    end
  end
end
