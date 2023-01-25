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

            ACTIONS
          end

          def current_train
            @game.depot.depot_trains.first
          end

          def can_purchase?(corp)
            current_train and room?(corp)
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

            @log << "#{@round.current_operator.name} exchanges the #{rocket.name} for a #{train.name} train"

            rocket.close!
            source = train.owner
            @game.buy_train(@round.current_operator, train, :free)
            @game.phase.buying_train!(@round.current_operator, train, source)
          end
        end
      end
    end
  end
end
