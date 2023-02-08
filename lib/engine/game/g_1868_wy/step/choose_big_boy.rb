# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module Step
        module ChooseBigBoy
          def setup
            super
            @chosen = false
          end

          def choice_actions(entity, cannot_pass: false)
            return [] unless entity.corporation?

            actions = []

            if (!@game.big_boy_train || !@chosen) && can_use_big_boy?(entity)
              if owns_big_boy?(entity)
                actions << 'choose'
                actions << 'pass' unless cannot_pass
              elsif !cannot_pass && can_buy_big_boy?(entity)
                actions << 'pass'
              end
            end

            actions
          end

          def choice_name
            if @game.big_boy_train
              "You may move the [+1+1] token from the #{@game.big_boy_train_original.name} train to another train"
            else
              'You may attach the [+1+1] token to a train'
            end
          end

          def choices
            big_boy_choices(current_entity).each_with_index.with_object({}) do |(train, index), choices|
              choices[index.to_s] = "#{train.name} train"
            end
          end

          def big_boy_choices(entity)
            entity.trains.reject { |t| t == @game.big_boy_train || t.obsolete }
          end

          def can_use_big_boy?(entity)
            !big_boy_choices(entity).empty?
          end

          def owns_big_boy?(entity)
            @game.big_boy_private&.corporation == entity
          end

          def can_buy_big_boy?(entity)
            @game.big_boy_private.owned_by_player? &&
              @game.phase.status.include?('can_buy_companies') &&
              @game.buying_power(entity).positive?
          end

          def process_choose_big_boy(action)
            train = big_boy_choices(action.entity)[action.choice.to_i]
            @game.attach_big_boy(train, action.entity)
            @chosen = true
          end

          def pass_if_cannot_buy_train?(entity)
            !can_use_big_boy?(entity) &&
              !(owns_big_boy?(entity) ||
                can_buy_big_boy?(entity))
          end
        end
      end
    end
  end
end
