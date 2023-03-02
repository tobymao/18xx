# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Mag
      module Step
        class Route < Engine::Step::Route
          BUY_ACTION = %w[special_buy].freeze
          RAILCAR_BASE = [10, 10, 20, 20].freeze
          CIWL_BASE = [30, 30, 50, 50].freeze

          def actions(entity)
            return [] if !entity.operator? || entity.runnable_trains.empty? || !@game.can_run_route?(entity)

            if buyable_items(entity).empty?
              ACTIONS
            else
              ACTIONS + BUY_ACTION
            end
          end

          def setup
            super

            @round.rail_cars = []
          end

          def log_skip(entity)
            super unless entity.corporation?
          end

          def process_run_routes(action)
            raise GameError, 'Must use all purchased rail-car benefits' unless @game.all_railcars_used?(action.routes)

            ciwl_income(action.routes) if @game.new_major?

            super
          end

          def ciwl_income(routes)
            red_to_red_route_count = @game.red_to_red(routes)

            return unless red_to_red_route_count.positive?

            income = CIWL_BASE[@game.phase.current[:tiles].size - 1] * red_to_red_route_count
            @game.bank.spend(income, @game.ciwl)
            @log << "#{@game.ciwl.name} earns #{@game.format_currency(income)}"
          end

          def buyable_items(entity)
            return [] unless entity.minor?
            return [] unless entity.minor?
            return [] unless entity.cash >= item_cost

            items = []

            if !@round.rail_cars.include?('G&C') && @game.multiplayer?
              items << Item.new(description: 'Plus Train Upgrade [G&C]', cost: item_cost)
            end

            if !@round.rail_cars.include?('RABA') && @game.multiplayer?
              items << Item.new(description: "+#{@game.raba_delta(@game.phase)} Offboard Bonus [RABA]",
                                cost: item_cost)
            elsif !@round.rail_cars.include?('RABA')
              items << Item.new(description: "+#{@game.raba_delta(@game.phase)} Offboard Bonus / Train Upgrade [RABA]",
                                cost: item_cost)
            end

            if !@round.rail_cars.include?('SNW') && @game.multiplayer?
              items << Item.new(description: 'Mine Access [SNW]', cost: item_cost)
            end

            items
          end

          def item_cost
            RAILCAR_BASE[@game.phase.current[:tiles].size - 1] + (10 * @round.rail_cars.size)
          end

          def round_state
            {
              routes: [],
              rail_cars: [],
            }
          end

          def process_special_buy(action)
            item = action.item
            desc = item.description
            corp = case desc
                   when /G&C/
                     @game.gc
                   when /RABA/
                     @game.raba
                   when /SNW/
                     @game.snw
                   end
            @round.rail_cars << corp.name

            action.entity.spend(item.cost, corp)
            @log << "#{action.entity.name} buys #{desc} for #{@game.format_currency(item.cost)}"
          end
        end
      end
    end
  end
end
