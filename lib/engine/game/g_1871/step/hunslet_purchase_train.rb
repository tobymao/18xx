# frozen_string_literal: true

module Engine
  module Game
    module G1871
      module Step
        class HunsletPurchaseTrain < Engine::Step::Base
          ACTIONS = %w[purchase_train].freeze

          def setup
            @hunslet = @game.company_by_id('HSE')
          end

          def description
            'Hunslet Train Purchase'
          end

          def active?
            !@hunslet.closed?
          end

          def actions(entity)
            return [] unless @hunslet == entity
            return [] if !current_entity.corporation? || current_entity != @hunslet.owner
            return [] unless can_purchase?(current_entity)

            ACTIONS
          end

          def current_train
            @game.depot.depot_trains.first
          end

          def can_purchase?(corp)
            train = current_train
            train and room?(corp) and corp.cash >= train.price
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
            hunslet = action.entity
            corporation = hunslet.owner
            train = current_train

            raise GameError, "#{corporation.name} can't purchase a #{train.name} train" unless can_purchase?(corporation)

            @log << "#{corporation.name} closes the #{hunslet.name} to purchase a "\
                    "#{train.name} train for #{@game.format_currency(train.price)}"
            hunslet.close!
            source = train.owner
            @game.buy_train(corporation, train, train.price)
            @game.phase.buying_train!(corporation, train, source)
          end
        end
      end
    end
  end
end
