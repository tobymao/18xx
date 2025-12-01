# frozen_string_literal: true

require_relative '../../g_1824/step/buy_sell_par_shares_first_sr'

module Engine
  module Game
    module G1824Cisleithania
      module Step
        class BuySellParSharesFirstSr < G1824::Step::BuySellParSharesFirstSr
          def actions(entity)
            actions = super

            return actions unless @game.two_player?

            actions.delete('pass') if stack_phase
            actions.delete('par') if stack_phase || mr_phase
            actions.delete('buy_shares') if stack_phase || mr_phase

            actions
          end

          def stack_phase
            @game.two_player? && @game.any_stacks_left?
          end

          def mr_phase
            @game.two_player? && !@game.any_stacks_left? && @game.unbought_companies?
          end

          def can_buy_company?(player, company)
            return allowed_to_buy_mr?(player) if @game.two_player? && @game.mountain_railway?(company)

            super
          end

          def visible_corporations
            return [] if @game.two_player? && @game.unbought_companies?

            super
          end

          def process_buy_company(action)
            return super unless @game.two_player?

            company = action.company
            player = action.entity

            if bought_from_different_stack?(company)
              raise GameError, "#{player.name} must buy from stack #{@game.current_stack} "\
                               "as #{other_player(player).name} bought from it"
            else
              @game.log << "#{player.name} buys from stack #{company.stack}" if company.stack
              @game.current_stack = @game.current_stack ? nil : company.stack
              if @game.current_stack
                @game.log << "#{other_player(player).name} must buy remaining from stack "\
                             "#{@game.current_stack}"
              end

              super
            end
          end

          def process_pass(action)
            if @game.two_player? && !@game.any_stacks_left? && @game.unbought_companies?
              # A player reject to buy a mountain railway, discard the one with the highest number
              @game.buyable_bank_owned_companies.last.close!
            end

            super
          end

          def pass_description
            if @round.current_actions.empty? && @game.two_player? && !@game.any_stacks_left? && @game.unbought_companies?
              # A player need to decide if they want to draft a mountain railway or not
              'Pass (Mountain Railway)'
            else
              super
            end
          end

          private

          def bought_from_different_stack?(company)
            @game.current_stack && @game.current_stack != company.stack
          end

          def bought_non_stack_entity_while_stacks_still_remain?(entity)
            return false if entity.company? && entity.stack

            @game.any_stacks_left?
          end

          def allowed_to_buy_mr?(player)
            return false if @game.any_stacks_left?

            @game.companies.count { |c| @game.mountain_railway?(c) && c.owner == player }.zero?
          end

          def other_player(player)
            @game.players.find { |p| p != player }
          end
        end
      end
    end
  end
end
