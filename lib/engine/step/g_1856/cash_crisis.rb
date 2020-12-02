# frozen_string_literal: true

require_relative '../g_1817/cash_crisis'
require_relative '../base'

module Engine
  module Step
    module G1856
      class CashCrisis < G1817::CashCrisis
        # 1856 Has several situations outside of buying trains where
        #  a president is forced to contribute funds (and may even go bankrupt)
        #  so reusing the 1817 CashCrisis makes sense
        def actions(entity)
          return [] unless entity == current_entity

          if @active_entity.nil?
            @active_entity = entity
            @game.log << "#{@active_entity.name} enters Emergency Fundraising and owes"\
            " the bank #{@game.format_currency(needed_cash(@active_entity))}"
          end

          ['sell_shares']
        end

        def description
          'Emergency Fundraising'
        end

        def can_sell?(entity, bundle)
          # Use Base's implementation
          Base.instance_method(:can_sell?).bind(self).call(entity, bundle)
        end
      end
    end
  end
end
