# frozen_string_literal: true

require_relative '../../g_1824/round/first_stock'

module Engine
  module Game
    module G1824Cisleithania
      module Round
        class FirstStock < G1824::Round::FirstStock
          def description
            return super unless @game.two_player?

            text = case @turn
                   when 1, 2, 3, 4
                     draft_stack(5 - @turn)
                   when 5
                     mountain_railway_drafting
                   else
                     super
                   end
            "Turn #{@turn}: #{text}"
          end

          def setup_pre_log_text
            return super unless @game.two_player?

            @game.log << 'During Initial Drafting one player selects one company from Stack 1-4, '\
                         'and the other player gets the other company in that Stack.'
            @game.log << 'No player may pass as long as there are still things in stacks.'
            @game.log << 'When all 4 Stacks have been drafted, each player get the option to buy a Mountain Railway. '\
                         'Any unsold Mountain Railways are discarded from the game.'
            @game.log << 'Thereafter the First Stock Round commences which has the same rules as standard 1824.'
            @game.log << 'NOTE! The two railways in stack 1 are construction railways which do not own '\
                         'nor run any trains, just build track for free. And the associated Regional Railway '\
                         'is a bond railway, which just payout - do not build nor own trains.'
          end

          def setup_post_log_text
            return super unless @game.two_player?

            @game.log << 'The player order is as follows:'
            @game.log << "Turn 1 : #{draft_stack(4)}: #{player_order_reversed}"
            @game.log << "Turn 2 : #{draft_stack(3)}: #{player_order_normal}"
            @game.log << "Turn 3 : #{draft_stack(2)}: #{player_order_normal}"
            @game.log << "Turn 4 : #{draft_stack(1)}: #{player_order_reversed}"
            @game.log << "Turn 5 : #{mountain_railway_drafting}: #{player_order_normal}"
            @game.log << "Turn 6+: Initial SR: #{player_order_normal}"
            log_player_order("for turn #{@turn}")
          end

          def do_handle_next_entity_index
            return super unless @game.two_player?

            @turn += 1
            case @turn
            when 4
              @reverse = true
              @entities = @game.players.reverse
              log_player_order("for turn #{@turn}")
            when 2, 3
              @reverse = false
              @entities = @game.players
              log_player_order("for turn #{@turn}")
            else
              @reverse = false
              @entities = @game.players
              return unless @turn == 5

              log_player_order('from now on')
            end
          end

          # Do not show auto pass button as long as there is drafting
          def show_auto?
            return false if @game.two_player? && @game.unbought_companies?

            super
          end

          def finish_round_text
            return super unless @game.two_player?
          end

          private

          def log_player_order(description)
            @game.log << ''
            @game.log << "Player order #{description} is #{@reverse ? 'reversed' : 'normal'}"
          end

          def player_order_normal
            "#{@game.players.first.name}, #{@game.players.last.name}"
          end

          def player_order_reversed
            "#{@game.players.last.name}, #{@game.players.first.name}"
          end

          def draft_stack(remaining_stacks)
            case remaining_stacks
            when 4
              'Draft 1st stack'
            when 3
              'Draft 2nd stack'
            when 2
              'Draft 3rd stack'
            when 1
              'Draft last stack'
            end
          end

          def mountain_railway_drafting
            'Draft Mountain Railway'
          end
        end
      end
    end
  end
end
