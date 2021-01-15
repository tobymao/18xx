# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18Mag
      class Route < Route
        BUY_ACTION = %w[special_buy].freeze
        RAILCAR_BASE = [10, 10, 20, 20].freeze

        def actions(entity)
          return [] if !entity.operator? || entity.runnable_trains.empty? || !@game.can_run_route?(entity)

          route_actions = ACTIONS
          route_actions.concat(BUY_ACTION) unless buyable_items(entity).empty?
          route_actions
        end

        def setup
          super

          @round.rail_cars = []
          @round.raba_trains = []
          @round.snw_train = nil
          @round.gc_train = nil
        end

        def log_skip(entity)
          super unless entity.corporation?
        end

        def buyable_items(entity)
          return [] unless entity.minor?
          return [] unless entity.minor?
          return [] unless entity.cash >= item_cost

          items = []

          unless @round.rail_cars.include?('G&C')
            items << Item.new(description: 'Plus-train Upgrade from G&C', cost: item_cost)
          end

          unless @round.rail_cars.include?('RABA')
            items << Item.new(description: 'Off Board Bonus from RABA', cost: item_cost)
          end

          unless @round.rail_cars.include?('SNW')
            items << Item.new(description: 'Mine Access from SNW', cost: item_cost)
          end

          items
        end

        def item_cost
          RAILCAR_BASE[@game.phase.current[:tiles].size - 1] + 10 * @round.rail_cars.size
        end

        def round_state
          {
            routes: [],
            rail_cars: [],
            raba_trains: [],
            snw_train: nil,
            gc_train: nil,
          }
        end

        def process_special_buy(action)
          item = action.item
          desc = item.description
          corp_str = desc[desc.index('from ') + 5..-1]
          corp = @game.corporation_by_id(corp_str)
          @round.rail_cars << corp_str

          action.entity.spend(item.cost, corp)
          @log << "#{action.entity.name} buys #{desc} for #{@game.format_currency(item.cost)}"
        end
      end
    end
  end
end
