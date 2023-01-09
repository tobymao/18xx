# frozen_string_literal: true

module Engine
  module Game
    module G1880
      module Step
        class RocketPurchaseTrain < Engine::Step::Base
          ACTIONS = %w[purchase_train].freeze

          def setup
            @rocket = @game.company_by_id('P7')
          end

          def description
            'Rocket of China Train Purchase'
          end

          def active?
            !@rocket.closed?
          end

          def actions(entity)
            return [] unless @rocket == entity
            return [] if !current_entity.corporation? || current_entity.owner != @rocket.owner
            return [] unless can_purchase?(current_entity)

            @buying_corp = current_entity
            ACTIONS
          end

          def current_train
            @game.depot.depot_trains.first
          end

          def can_purchase?(corp)
            train = current_train
            train and room?(corp)
          end

          def room?(corp)
            corp.trains.size < @game.train_limit(corp)
          end

          # Don't want any skipped message for this step
          def log_skip(_entity); end

          def blocking?
            false
          end

          def process_purchase_train(action)
            rocket = action.entity
            train = current_train

            raise GameError, "#{@buying_corp.name} can't purchase a #{train.name} train" unless can_purchase?(@buying_corp)

            @log << "#{@buying_corp.name} exchanges the #{rocket.name} for a #{train.name} train"

            rocket.close!
            @game.buy_train(@buying_corp, train, :free)
            @game.phase.buying_train!(@buying_corp, train)
          end
        end
      end
    end
  end
end
