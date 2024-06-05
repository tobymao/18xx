# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1849
      module Step
        class BuyEToken < Engine::Step::Base
          def actions(entity)
            actions = super.dup
            actions += %w[choose pass] if can_buy_e_token?(entity)

            actions.uniq
          end

          def description
            'Buy E-Token'
          end

          def pass_description
            'Pass'
          end

          def choices
            choices = []
            choices << ["Buy E-Token for #{@game.format_currency(e_token_cost)}"] if can_buy_e_token?(current_entity)
            choices
          end

          def choice_name
            'E-Token allows the purchase of E-Trains'
          end

          def log_skip(entity)
            super if @game.electric_dreams? && @game.phase.status.include?('e_tokens_available')
          end

          def auto_actions(entity)
            return [Engine::Action::Pass.new(entity)] unless can_buy_e_token?(entity)

            super
          end

          def e_token_cost
            if @game.e_token_sold
              @game.phase.name == '12H' ? 800 : 550
            else
              @game.phase.name == '12H' ? 1100 : 800
            end
          end

          def process_choose(action)
            raise GameError, 'Cannot buy E-token' unless can_buy_e_token?(action.entity)

            buy_e_token(action.entity) if action.choice == "Buy E-Token for #{@game.format_currency(e_token_cost)}"
          end

          def buy_e_token(corporation)
            total_cost = e_token_cost
            corporation.spend(total_cost, @game.bank)
            @log << "#{corporation.name} buys an E-Token for #{@game.format_currency(total_cost)}."
            @log << "#{corporation.name} can now buy E-Trains."
            corporation.e_token = true
            @game.e_token_sold = true
          end

          def can_buy_e_token?(entity)
            @game.electric_dreams? &&
              entity.corporation? &&
              @game.phase.status.include?('e_tokens_available') &&
              !entity.e_token &&
              entity.cash >= e_token_cost
          end
        end
      end
    end
  end
end
