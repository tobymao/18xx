# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18OE
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def must_buy_train?(entity)
            entity.floated? && entity.trains.empty? && (!@game.fulfilled_train_obligation?(entity) || entity.type == :major)
          end

          def buyable_trains(entity)
            trains = super

            # Level 8 trains only available after 4th level-7 purchase (§11.6)
            if level8_available?
              if trains.none? { |t| t.name == '8+8' }
                lvl8 = @game.depot.upcoming.find { |t| t.name == '8+8' }
                trains = trains + [lvl8] if lvl8
              end
            else
              trains = trains.reject { |t| t.name == '8+8' }
            end

            return trains unless @game.train_obligation_active?

            if @game.fulfilled_train_obligation?(entity)
              return [] unless @game.non_starter_trains_available?

              trains.reject { |t| t.name == '2+2' }
            else
              trains.select { |t| t.name == '2+2' && t.from_depot? }
            end
          end

          def process_buy_train(action)
            super
            @game.fulfill_train_obligation!(action.entity) if action.train.name == '2+2' && action.train.from_depot?
          end

          # TODO: Nationals claiming rusted trains for free (openpoints §1.9, §3.7) — deferred

          private

          def level8_available?
            level7_remaining = @game.depot.upcoming.count { |t| t.name == '7+7' }
            level7_total = @game.depot.trains.count { |t| %w[7+7 4D].include?(t.name) }
            level7_total - level7_remaining >= 4
          end
        end
      end
    end
  end
end
