# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1824
      module Step
        class KkTokenChoice < Engine::Step::Base
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless @game.kk_token_choice_player

            ['choose']
          end

          def active_entities
            return [] unless @game.kk.owner

            [@game.kk_token_choice_player]
          end

          def description
            'Token Choice'
          end

          def active?
            !active_entities.empty?
          end

          def choice_available?(entity)
            entity == @game.kk_token_choice_player
          end

          def can_sell?
            false
          end

          def ipo_type(_entity)
            nil
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

          def choices
            ['Return one token', 'Return the other token']
          end

          def choice_name
            "Choose Wien token to return to #{@game.kk.name} charter as a regular token"
          end

          def process_choose(action)
            player = action.entity

            choice = action.choice == 'Return one token' ? 1 : 2
            @log << "#{player.name} removes selected #{@game.kk.name} token from Wien, and put it as a "\
                    "#{@game.format_currency(40)} token on the #{@game.kk.name} charter"
            @game.return_kk_token(choice)
          end
        end
      end
    end
  end
end
