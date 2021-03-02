# frozen_string_literal: true

require_relative '../../../round/operating'
require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18ZOO
      module Round
        class Operating < Engine::Round::Operating
          def after_setup
            super

            @game.corporations.each do |corporation|
              corporation.all_abilities
                         .select { |ability| ability.is_a?(Engine::Ability::Close) }
                         .each do |ability|
                ability.corporation.operated = true
                corporation.remove_ability ability
              end
            end
          end
        end
      end
    end
  end
end
