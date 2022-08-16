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
        end
      end
    end
  end
end
