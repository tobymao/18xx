# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'choose_big_boy'

module Engine
  module Game
    module G1868WY
      module Step
        # Choose a train for the [+1+1] token right when the "Big Boy" private
        # is bought by a corporation; apart from this first chance to choose a
        # train, a train may only be chosen during the BuyTrain step
        class Choose < Engine::Step::Base
          include G1868WY::Step::ChooseBigBoy

          def description
            'Choose a Train'
          end

          def actions(entity)
            !@game.big_boy_first_chance && owns_big_boy?(entity) ? choice_actions(entity) : []
          end

          def log_skip(_entity); end

          def pass_description
            'Pass (Choose a Train)'
          end

          def skip!
            @game.big_boy_first_chance = true if @game.big_boy_private.corporation
          end

          def process_pass(action)
            @game.big_boy_first_chance = true
            log_pass(action.entity)
            pass!
          end

          def process_choose(action)
            @game.big_boy_first_chance = true
            process_choose_big_boy(action)
          end

          def blocks?
            !@game.big_boy_first_chance
          end
        end
      end
    end
  end
end
