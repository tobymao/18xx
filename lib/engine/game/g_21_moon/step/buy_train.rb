# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G21Moon
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          MAX_BY_BASE = 2

          def setup
            super
            @destination_bases = []
          end

          def process_buy_train(action)
            base = action.slots.first.to_i.zero? ? :lb : :sp
            raise GameError, 'No room for LB train' if base == :lb && !room_for_lb?(action.entity)
            raise GameError, 'No room for SP train' if base == :sp && !room_for_sp?(action.entity)

            super
            @game.assign_base(action.train, base)
            @destination_bases << base
          end

          def room?(entity, _shell = nil)
            room_for_lb?(entity) || room_for_sp?(entity)
          end

          def room_for_lb?(entity)
            !@destination_bases.include?(:lb) && @game.lb_trains(entity).size < MAX_BY_BASE
          end

          def room_for_sp?(entity)
            !@destination_bases.include?(:sp) && @game.sp_trains(entity).size < MAX_BY_BASE
          end

          def slot_dropdown?(_corp)
            true
          end

          def slot_dropdown_title(_corp)
            'Select destination for purchased train:'
          end

          def slot_dropdown_options(corp)
            options = []
            options << { slot: 0, text: 'Local Base' } if room_for_lb?(corp)
            options << { slot: 1, text: 'Space Port Base' } if room_for_sp?(corp)
            options
          end
        end
      end
    end
  end
end
