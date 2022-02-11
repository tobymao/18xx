# frozen_string_literal: true

module Engine
  module Game
    module G18USA
      module Step
        module ScrapTrainModule
          def scrappable_trains(entity)
            entity.trains.select { |t| @game.pullman_train?(t) }
          end

          def scrap_info(_)
            @game.scrap_info
          end

          def scrap_button_text(_)
            @game.scrap_button_text
          end
        end
      end
    end
  end
end
