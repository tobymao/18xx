# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1826
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            # Can't buy trains from other corporations until phase 6H
            return super if @game.phase.status.include?('can_buy_trains')

            super.select(&:from_depot?)
          end

          def buy_train_action(action)
            super

            return unless action.train.name == 'E'
            return unless action.train.from_depot?

            @game.e_trains_purchased += 1
            case @game.e_trains_purchased
            when 1
              @game.e_train_range = 2
            when 2, 3
              @game.e_train_range = 3
            when 4
              @game.e_train_range = 4
            end
            @log << "#{e_trains_purchased} E-trains have been sold. E-trains now run #{@game.e_train_range} "\
                    'stops, skipping towns, and count each stop twice.'
          end
        end
      end
    end
  end
end
