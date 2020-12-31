# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1824
      class BuySellParShares < BuySellParShares
        def actions(_entity)
          result = super
          result << 'buy_company' unless result.empty?
          result
        end

        def can_buy?(_entity, bundle)
          super && !@game.abilities(bundle.corporation, :no_buy)
        end

        def can_sell?(_entity, bundle)
          super && !@game.abilities(bundle.corporation, :no_buy)
        end

        def can_gain?(_entity, bundle)
          super && !@game.abilities(bundle.corporation, :no_buy)
        end

        def process_buy_company(action)
          entity = action.entity
          company = action.company

          super

          return unless (minor = @game.minor_by_id(company.id))

          @game.log << "Minor #{minor.full_name} floats"
          minor.owner = entity
          minor.float!
        end
      end
    end
  end
end
