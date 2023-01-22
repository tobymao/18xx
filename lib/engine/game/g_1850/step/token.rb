# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1850
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            actions = super.dup
            actions += %w[choose pass] if can_buy_mesabi_token?(entity)

            actions.uniq
          end

          def choice_name
            'Buy Mesabi token?'
          end

          def choices
            ['Buy Token']
          end

          def description
            'Mesabi Token'
          end

          def process_choose(action)
            corp = action.entity
            total_cost = 80
            amount_to_owner = @game.mesabi_company.closed? ? 0 : 40
            amount_to_bank = amount_to_owner.positive? ? 40 : 80

            corp.spend(amount_to_bank, @game.bank)
            corp.spend(amount_to_owner, @game.mesabi_company.owner) if amount_to_owner.positive?

            log_message = "#{corp.name} buys a Mesabi token for #{@game.format_currency(total_cost)}. "
            if amount_to_owner.positive?
              log_message += "#{@game.mesabi_company.owner.name} receives #{@game.format_currency(amount_to_owner)}"
            end
            @log << log_message
            corp.mesabi_token = true
            pass!
          end

          def skip!
            pass!
          end

          def can_buy_mesabi_token?(entity)
            entity.corporation? &&
            !entity.mesabi_token &&
            @game.mesabi_compnay_sold_or_closed &&
            @game.mesabi_token_counter.positive? &&
            entity.cash >= 80
          end
        end
      end
    end
  end
end
