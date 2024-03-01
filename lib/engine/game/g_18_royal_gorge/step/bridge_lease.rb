# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18RoyalGorge
      module Step
        class BridgeLease < Engine::Step::Base
          def description
            corp = @game.hanging_bridge_corp
            "#{corp&.name} owes #{@game.rio_grande.name} #{formatted_payment}"
          end

          def actions(entity)
            blocks? && entity == @game.hanging_bridge_corp ? ['choose'] : []
          end

          def log_skip(_entity); end

          def blocks?
            @round.hanging_bridge_lease_payment.positive?
          end

          def process_choose(action)
            spender =
              case action.choice
              when 'corporation'
                @game.hanging_bridge_corp
              when 'president'
                @game.hanging_bridge_corp.owner
              end

            spender.spend(@round.hanging_bridge_lease_payment, @game.rio_grande)
            @log << "#{spender.name} pays #{@game.rio_grande.name} #{formatted_payment} for use of the Hanging Bridge"

            @round.hanging_bridge_lease_payment = 0
          end

          def formatted_payment
            @game.format_currency(@round.hanging_bridge_lease_payment)
          end

          def choice_name
            "#{@game.hanging_bridge_corp.name} or its President must pay "\
              "#{@game.rio_grande.name} #{formatted_payment} for use of the Hanging Bridge"
          end

          def choices
            {
              'corporation' => "#{@game.hanging_bridge_corp.name} - has "\
                               "#{@game.format_currency(@game.hanging_bridge_corp.cash)}",
              'president' => "#{@game.hanging_bridge_corp.owner.name} - has "\
                             "#{@game.format_currency(@game.hanging_bridge_corp.owner.cash)}",
            }
          end
        end
      end
    end
  end
end
