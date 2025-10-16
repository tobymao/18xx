# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1849
      module Step
        class LoanChoice < Engine::Step::Base
          def actions(entity)
            return [] unless entity == current_entity

            ['choose']
          end

          def active_entities
            return [] unless @game.loan_choice_player

            [@game.loan_choice_player]
          end

          def description
            'Bankruptcy Choice'
          end

          def active?
            !active_entities.empty?
          end

          def choice_available?(entity)
            entity == @game.loan_choice_player
          end

          def can_sell?
            false
          end

          def ipo_type(_entity)
            nil
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

          def choices
            ["Take #{@game.format_currency(500)} loan", 'Leave game']
          end

          def choice_name
            'Bankruptcy Decision'
          end

          def process_choose(action)
            player = action.entity

            if action.choice == 'Leave game'
              @log << "#{player.name} chooses to leave game"
              @game.declare_bankrupt(player)
            else
              @log << "#{player.name} chooses to take #{@game.format_currency(500)} loan
                     and reduce #{@game.format_currency(750)} from their score."

              # game end penalty instead of paying loan back
              player.take_cash_loan(500, @game.bank, interest: -100)
              player.penalty += 750
            end

            @game.loan_choice_player = nil
          end
        end
      end
    end
  end
end
