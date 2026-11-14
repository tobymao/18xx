# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module Step
        module CrossWaterFee
          def cross_water_fee!(action)
            return action.cost || 0 if @game.loading

            fee = yield
            if action.cost && action.cost != fee
              raise GameError, "Cross-water fee #{@game.format_currency(action.cost)} does not match " \
                               "#{@game.format_currency(fee)}"
            end

            action.cost = fee
          end

          def pay_cross_water_fee!(entity, fee)
            return unless fee.positive?

            entity.spend(fee, @game.bank)
            @game.log << "#{entity.name} pays #{@game.format_currency(fee)} to cross water"
          end
        end
      end
    end
  end
end
