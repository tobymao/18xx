# frozen_string_literal: true

require_relative '../../../step/special_buy_train'

module Engine
  module Game
    module G1848
      module Step
        class SpecialBuyTrain < Engine::Step::SpecialBuyTrain
          def process_buy_train(action)
            super
            # special ability is both on player and corporate, remove all left over abilities
            company = action.entity
            @game.ability_used!(company)
            return unless @game.private_closed_triggered

            # close company if company closes and the ability has been used
            @log << "#{company.name} closes"
            company.close!
          end

          def ability(entity, train: nil)
            return unless entity&.company?

            @game.abilities(entity, :train_discount, time: ability_timing) do |ability|
              break unless entity.owner == @game.current_entity || entity.owner == @game.current_entity.owner
              return ability if !train || ability.trains.include?(train.name)
            end

            nil
          end
        end
      end
    end
  end
end
