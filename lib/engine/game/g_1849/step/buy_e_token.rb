# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1849
      module Step
        class BuyEToken < Engine::Step::Base
          def actions(entity)
            return [] if !@game.electric_dreams? || !entity.corporation? || entity != current_entity

            actions = []
            actions += %w[choose pass] if can_buy_e_token?(entity)
            actions
          end

          def description
            'Buy E-Token'
          end

          def pass_description
            'Pass'
          end

          def choices
            choices = []
            choices << ["Buy E-Token for #{@game.format_currency(e_token_cost)}"]
            choices
          end

          def choice_name
            'E-Token allows the purchase of E-Trains'
          end

          def log_skip(entity)
            super if @game.electric_dreams?
          end

          def log_pass(entity)
            super if @game.electric_dreams?
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

            buy_e_token(action.entity)
            new_ability = Engine::Ability::Description.new(
              type: 'description',
              description: 'E-Token',
            )
            action.entity.add_ability(new_ability)
          end

          def buy_e_token(corporation)
            return unless can_buy_e_token?(corporation)

            total_cost = e_token_cost
            corporation.spend(total_cost, @game.bank)
            @log << "#{corporation.name} buys an E-Token for #{@game.format_currency(total_cost)}."
            @log << "#{corporation.name} can now buy E-Trains."
            @game.e_token_sold = true
          end

          def can_buy_e_token?(entity)
            @game.electric_dreams? &&
              entity.corporation? &&
              @game.e_tokens_enabled &&
              !@game.e_token?(entity) &&
              entity.cash >= e_token_cost
          end
        end
      end
    end
  end
end
