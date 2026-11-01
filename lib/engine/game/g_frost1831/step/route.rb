# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module GFrost1831
      module Step
        class Route < Engine::Step::Route
          def log_skip(entity)
            return if entity.type == :faction

            super
          end

          def actions(entity)
            return %w[choose] if entity&.company? && entity.sym == 'FAV'

            super
          end

          def process_choose(action)
            return unless action.entity&.sym == 'FAV'

            special_choose = @round.steps.find { |s| s.is_a?(GFrost1831::Step::SpecialChoose) }
            special_choose&.process_choose_ability(action)
          end
        end
      end
    end
  end
end
