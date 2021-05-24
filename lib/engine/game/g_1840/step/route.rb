# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1840
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.corporation? || entity.type == :major

            base = super

            base << 'scrap_train' if entity.type == :minor && !entity.trains.empty?
            base
          end

          def log_skip(entity)
            @log << "#{entity.name} skips #{description.downcase}" unless entity.type == :major
          end

          def scrappable_trains(entity)
            return [] if entity.type != :minor

            @game.scrappable_trains(entity)
          end

          def scrap_info(train)
            @game.scrap_info(train)
          end

          def scrap_button_text(_train)
            @game.scrap_button_text
          end

          def process_scrap_train(action)
            @game.scrap_train(action.train, action.entity)
          end
        end
      end
    end
  end
end
