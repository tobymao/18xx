# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18Uruguay
      module Step
        class RouteRptla < Engine::Step::Route
          SHIP_CAPACITY =
            {
              'Ship 1' => 1,
              'Ship 2' => 1,
              'Ship 3' => 2,
              'Ship 4' => 2,
              'Ship 5' => 3,
              'Ship 6' => 3,
            }.freeze

          def description
            'Ship to England'
          end

          def setup
            @goods_shipped = 0
          end

          def actions(entity)
            return [] unless entity == @game.rptla

            %w[run_routes choose].freeze
          end

          def log_skip(entity)
            return unless entity == @game.rptla

            super
          end

          def choosing?(_entity)
            true
          end

          def choice_name
            'Attach goods to ships'
          end

          def choices
            choices = {}
            number_of_goods = [@game.number_of_goods_at_harbor, total_ship_capacity?(current_entity)].min
            number_of_goods.times do |count|
              choices[count] = '1 Good' if count.zero?
              choices[count] = (count + 1).to_s + ' Goods' if count.positive?
            end
            choices
          end

          def ship_capacity(train)
            SHIP_CAPACITY[train.name.partition('+')[0]]
          end

          def total_ship_capacity?(entity)
            trains = @game.route_trains(entity)
            trains.sum { |train| ship_capacity(train) }
          end

          def process_choose(action)
            entity = action.entity
            goods_to_deliver = action.choice.to_i + 1
            ships = @game.route_trains(entity)
            return unless ships
            return unless ships.length.positive?

            remaining = goods_to_deliver
            ships.each do |ship|
              ship.name = ship.name.partition('+')[0] unless ship.nil?
              capacity = ship_capacity(ship)
              goods_count = [remaining, capacity].min
              remaining -= goods_count
              @game.add_goods_to_ship(ship, goods_count)
            end
            @goods_shipped = goods_to_deliver - remaining
          end

          def process_run_routes(action)
            super
            entity = action.entity
            @game.remove_goods_from_rptla(@goods_shipped) if @goods_shipped.positive? && entity == @game.rptla
            @log << "#{entity.id} ships #{@goods_shipped} good to England" if @goods_shipped == 1 && entity == @game.rptla
            @log << "#{entity.id} ships #{@goods_shipped} goods to England" if @goods_shipped > 1 && entity == @game.rptla
            @game.route_trains(entity)&.each do |ship|
              @game.remove_goods_from_ship(ship)
            end
          end
        end
      end
    end
  end
end
