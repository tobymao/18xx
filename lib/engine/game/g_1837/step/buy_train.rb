# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1837
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity != current_entity

            actions = super.clone
            unless scrappable_trains(entity).empty?
              actions << 'pass' if actions.empty?
              actions << 'scrap_train'
            end
            actions
          end

          def buyable_train_variants(train, entity)
            variants = super
            variants.select! { |t| @game.goods_train?(t[:name]) } if entity.type == :coal
            variants
          end

          def other_trains(entity)
            trains = super
            trains.select! { |t| @game.goods_train?(t.name) } if entity.type == :coal
            trains
          end

          def can_entity_buy_train?(_entity)
            true
          end

          def scrappable_trains(entity)
            return [] if @game.num_corp_trains(entity) < @game.train_limit(entity)

            entity.trains.select { |t| surrender_cost(t) <= entity.cash }
          end

          def surrender_cost(train)
            train.price / 2
          end

          def scrap_info(_train)
            ''
          end

          def scrap_button_text(train)
            "Surrender (#{@game.format_currency(-surrender_cost(train))})"
          end

          def scrap_header_text
            'Trains to Surrender'
          end

          def process_scrap_train(action)
            entity = action.entity
            train = action.train
            raise GameError, 'Can only scrap trains owned by the corporation' if entity != train.owner

            @log << "#{entity.name} spends #{@game.format_currency(surrender_cost(train))} to surrender" \
                    " a #{train.name} train to the bank"
            entity.spend(surrender_cost(train), @game.bank)
            @game.depot.reclaim_train(train)
          end
        end
      end
    end
  end
end
