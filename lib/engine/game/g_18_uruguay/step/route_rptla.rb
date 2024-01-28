# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18Uruguay
      module Step
        class RouteRptla < Engine::Step::Route
          def setup
            @goods_shipped = 0
          end

          def actions(entity)
            return [] unless entity.corporation == @game.rptla

            %w[run_routes choose].freeze
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
            (train.name.scan(/\d/)[0].to_f / 2).ceil
          end

          def total_ship_capacity?(entity)
            trains = @game.route_trains(entity)
            total_capacity = 0
            trains.each do |train|
              total_capacity += ship_capacity(train)
            end
            total_capacity
          end

          def process_choose(action)
            entity = action.entity
            goods_to_deliver = action.choice.to_i + 1
            trains = @game.route_trains(entity)
            return unless trains
            return unless trains.length.positive?

            remaining = goods_to_deliver
            trains.each do |train|
              train.name = train.name.partition('+')[0] unless train.nil?
              capacity = ship_capacity(train)
              goods_count = [remaining, capacity].min
              remaining -= goods_count
              train.name += '+' + @game.class::GOODS_TRAIN + '(' + goods_count.to_s + ')' if goods_count.positive?
            end
            @goods_shipped = goods_to_deliver - remaining
          end

          def process_run_routes(action)
            super
            entity = action.entity
            @game.remove_goods_from_rptla(@goods_shipped) if @goods_shipped.positive? && entity == @game.rptla
            @log << "#{entity.id} ships #{@goods_shipped} good to England" if @goods_shipped == 1 && entity == @game.rptla
            @log << "#{entity.id} ships #{@goods_shipped} goods to England" if @goods_shipped > 1 && entity == @game.rptla
            @game.route_trains(entity)&.each do |train|
              train.name = train.name.partition('+')[0] unless train.nil?
            end
          end
        end
      end
    end
  end
end
