# frozen_string_literal: true

require_relative '../../g_1824/round/first_stock'

module Engine
  module Game
    module G1824Cisleithania
      module Round
        class FirstStock < G1824::Round::FirstStock
          def description
            return 'Initial Drafting' if @game.two_player? && @game.any_stacks_left?

            super
          end

          def setup_pre_log_text
            return super unless @game.two_player?

            @game.log << 'During Initial Drafting one player selects one company from Stack 1-4, '\
                         'and the other player gets the other company in that Stack. The order will '\
                         'be reversed for the second stack, then normal.'
            @game.log << 'No player may pass as long as there are still things in stacks.'
            @game.log << 'After all Stacks have been drafted, then First Stock Round starts.'
            @game.log << 'During the First Stock Round players can optionally buy ONE Mountain Railway '\
                         'and shares. Any unsold Mountain Railways will be removed from the game.'
            @game.log << 'NOTE! The two railways in stack 1 are construction railways which do not own '\
                         'nor run any trains, just build track for free. And the associated Regional Railway '\
                         'is a bond railway, which just payout - do not build nor own trains.'
          end

          def setup_post_log_text
            return super unless @game.two_player?

            @log << "Player order is reversed when selecting the first stack, that is #{@game.players.first.name} "\
                    'selects first'
          end

          def do_handle_next_entity_index
            if @game.two_player? && @game.any_stacks_left?
              if @game.remaining_stacks == 1
                @reverse = true
                @entities = @game.players.reverse
                @game.log << 'Player order is reversed when selecting from the last stack, '\
                             "that is #{@game.players.last.name} selects first"
              else
                @reverse = false
                @entities = @game.players
                @game.log << 'Player order is normal when selecting from the 2nd and 3rd stacks, '\
                             "that is #{@game.players.first.name} selects first"
              end
            else
              super
            end
          end
        end
      end
    end
  end
end
