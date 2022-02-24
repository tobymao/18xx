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
            "Scrap Pullman for #{@game.format_currency(pullman_scrap_value)}"
          end

          def scrap_button_text(_)
            'Scrap Pullman'
          end

          def pullman_scrap_value
            50
          end

          def scrap_trains_button_only?
            true
          end

          # owner is the alleged owner of the company scrapping a pullman
          def scrap_train_by_owner(action, _owner)
            entity = action.entity
            raise GameError, "#{entity.name} cannot scrap a train now" unless entity.owned_by?(current_entity)

            train = action.train
            raise GameError, "#{entity.name} cannot scrap a #{train.name} train" unless @game.pullman_train?(train)

            scrap_train(train)
          end

          # Do error checking before calling this.
          def scrap_train(train)
            @game.bank.spend(pullman_scrap_value, train.owner)
            @game.log << "#{train.owner.name} scraps a pullman for #{@game.format_currency(pullman_scrap_value)}"
            @game.depot.reclaim_train(train)
            # @game.reset_crowded_corps
          end

          def can_scrap_train?(entity)
            return false unless entity&.corporation?
            return false unless entity.owned_by?(current_entity)

            entity.trains.find { |t| @game.pullman_train?(t) }
          end

          def process_scrap_train(action)
            @corporate_action = action
            scrap_train_by_owner(action, current_entity)
          end
        end
      end
    end
  end
end
