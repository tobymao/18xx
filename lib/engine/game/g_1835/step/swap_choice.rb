# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1835
      module Step
        class SwapChoice < Engine::Step::Base
          def round_state
            super.merge(
              {
                swap_presidents_share: nil,
                swap_choice_player: nil,
                swap_location: nil,
                swap_other_player: nil,
                swap_for_higher_percentage: true,
              }
            )
          end

          def actions(entity)
            return [] unless entity == current_entity

            ['choose']
          end

          def active_entities
            return [] unless @round.swap_choice_player

            [@round.swap_choice_player]
          end

          def description
            'Swap choice for Presidency share'
          end

          def active?
            !active_entities.empty?
          end

          def choice_available?(entity)
            entity == @round.swap_choice_player
          end

          def can_sell?
            false
          end

          def ipo_type(_entity)
            nil
          end

          def choices
            choices = {}
            choices['keep_one'] = "One #{denominations[0]}% cert"
            choices['swap_for_two'] = "Two #{denominations[1]}% certs"
            choices
          end

          def choice_name
            "Old director: Choose the shares to receive in exchange for your #{denominations[0]}% presidency share"
          end

          def process_choose(action)
            choice = action.choice
            entity = action.entity

            case choice
            when 'swap_for_two'
              @log << "#{entity.name} chooses two #{denominations[1]}% certificates"
              @round.swap_for_higher_percentage = false
            else
              @log << "#{entity.name} chooses one #{denominations[0]}% certificate"
              @round.swap_for_higher_percentage = true
            end

            @game.share_pool.change_president(@round.swap_presidents_share, @round.swap_location, @round.swap_other_player,
                                              @round.swap_choice_player)

            @round.swap_choice_player = nil
            @round.swap_location = nil
            @round.swap_other_player = nil
            @round.swap_presidents_share = nil
          end

          private

          def denominations
            @round.swap_presidents_share.corporation == @game.prussian ? [10, 5] : [20, 10]
          end
        end
      end
    end
  end
end
