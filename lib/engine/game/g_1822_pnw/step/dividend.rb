# frozen_string_literal: true

require_relative '../../g_1822/step/dividend'

module Engine
  module Game
    module G1822PNW
      module Step
        class Dividend < Engine::Game::G1822::Step::Dividend
          def process_dividend(action)
            portage_usage_fee = @round.routes.sum { |route| @game.portage_penalty(route) }
            portage_corporation = @game.company_by_id('P16')&.owner
            if portage_corporation&.corporation? && portage_usage_fee.positive?
              @game.log << "#{portage_corporation.name} receives #{@game.format_currency(portage_usage_fee)} " \
                           'usage fee for portage tiles'
              @game.bank.spend(portage_usage_fee, portage_corporation)
            end
            super
          end

          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            price = entity.share_price.price
            times = 0
            times = 1 if revenue >= price || entity.type == :minor
            times = 2 if revenue >= price * 2 && entity.type == :major
            times = 3 if revenue >= price * 3 && price <= 150 && entity.type == :major
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end
        end
      end
    end
  end
end
