# frozen_string_literal: true

require_relative '../../g_1870/step/buy_sell_par_shares'

module Engine
  module Game
    module G1832
      module Step
        class BuySellParShares < G1870::Step::BuySellParShares
          def visible_corporations
            @game.sorted_corporations.reject { |item| item.type == :system unless item.floated? }
          end

          def can_exchange_any?(entity)
            return false unless entity.player?
            return false if entity.companies.none? { |company| company.id == 'P4' }

            # Can only exchange if there are shares available from an ipoed corp that has not yet operated
            @game.corporations.any? do |corp|
              corp.ipoed && !corp.operating_history.empty? && corp.num_ipo_shares.positive?
            end
          end
        end
      end
    end
  end
end
