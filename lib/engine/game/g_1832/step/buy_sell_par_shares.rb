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

            entity.companies.each do |company|
              next unless company.id == 'P4'

              # Only true if there are shares available from an ipoed corp that has not yet operated
              corps = @game.corporations.select(&:ipoed).reject do |c|
                c.operating_history.size.positive?
              end

              corps.each do |c|
                return true unless c.num_ipo_shares.empty
              end
            end

            false
          end
        end
      end
    end
  end
end
