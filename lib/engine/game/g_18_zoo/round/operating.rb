# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Round
        class Operating < Engine::Round::Operating
          def after_setup
            super

            @game.corporations.each do |corporation|
              corporation.all_abilities.each do |ability|
                next unless ability.is_a?(Engine::G18ZOO::Ability::DisableTrain)

                ability.train.operated = true
                corporation.remove_ability ability
              end
            end
          end
        end
      end
    end
  end
end
