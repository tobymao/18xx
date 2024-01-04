# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18Uruguay
      module Step
        class Route < Engine::Step::Route
          def setup
            @goods_train = nil
            @round.current_routes = []

            @train_goods_combos = []
          end

          def actions(entity)
            return %w[run_routes choose].freeze if entity.corporation == @game.rptla
            return [] if !entity.operator? || @game.route_trains(entity).empty? || !@game.can_run_route?(entity)
            return [] if entity.corporation? && entity.type == :minor

            actions = ACTIONS.dup
            actions << 'choose' if choosing?(entity)
            actions
          end

          def route_for_node(entity)
            @routes = []
            route = Engine::Route.new(
              @game,
              @game.phase,
              entity.trains.first,
              revenue: 999,
              revenue_str: 'aaa',
              routes: @routes
            )
            route.touch_node(@game.hex_by_id('A9').tile.cities.first)
            route.touch_node(@game.hex_by_id('A11').tile.offboards.first)

            route
          end

          def choosing?(_entity)
            true
          end

          def attach_good_to_train(train, hex)
            train.name += '+' + @game.class::GOODS_TRAIN + '(' + hex.id + ')' if hex
          end

          def choice_name
            return 'Attach goods to ships' if current_entity == @game.rptla

            'Attach good to a train'
          end

          def goods_hexes
            @game.hexes.select do |hex|
              hex.assignments.keys.find { |a| a.include? 'GOODS' }
            end
          end

          def ship_choices
            choices = {}
            number_of_goods = [@game.number_of_goods_at_harbor, total_ship_capacity?(current_entity)].min
            number_of_goods.times do |count|
              choices[count] = '1 Good' if count.zero?
              choices[count] = (count + 1).to_s + ' Goods' if count.positive?
            end
            choices
          end

          def choices
            choices = {}
            goods_train_choices(current_entity).each_with_index do |train, _index|
              hex = train['hex']
              index_str = "train\##{train['train_index']}"
              index_str += "_#{train['hex'].id}" unless hex.nil?
              choices[index_str] = "#{train['train'].name} train\##{train['train_index']} (#{train['hex'].id})" unless hex.nil?
              choices[index_str] = "#{train['train'].name} train\##{train['train_index']} unload" if hex.nil?
            end
            choices = ship_choices if current_entity == @game.rptla
            choices
          end

          def get_good_hex(train)
            m = train.name.match(/.*(\d)\+Goods\((\w\d)\).*/)
            goods_train = Struct.new(:train_id, :hex_id).new(*m.captures)
            @game.hex_by_id(goods_train.hex_id)
          end

          def detach_goods(routes)
            routes.each do |route|
              train = route.train
              next unless @game.train_with_goods?(train)

              hex = get_good_hex(train)
              good = hex.assignments.keys.find { |a| a.include? 'GOODS' }
              raise NoToken, "No good token found at Hex #{hex&.id}" if good.nil?
              raise NoToken, "Hex #{hex&.id} is not included in route for train #{train.name}" unless route.hexes.include?(hex)

              hex.remove_assignment!(good)
              @log << "#{current_entity.id} moves a good to the harbor"
              @game.add_good_to_rptla unless good.nil?
              unload_good(train)
            end
          end

          def route_for_train(train)
            @round.current_routes.each do |route|
              return route if route.train == train
            end
            nil
          end

          def get_train_goods_combo(name)
            str_split = name.split('_')
            train_index = str_split[0].split('#')[1]
            train = @game.route_trains(current_entity)[train_index.to_i - 1]
            hex = @game.hex_by_id(str_split[1]) if str_split.size > 1
            [train, hex]
          end

          def goods_train_choices(entity)
            choices_array = []
            @game.route_trains(entity).each_with_index do |train, index|
              route = route_for_train(train)
              if @game.train_with_goods?(train)
                choices_array.push({ train: train, train_index: index + 1, hex: nil, loaded: true })
              else
                goods_hexes.each do |hex|
                  if route
                    val = { train: train, train_index: index + 1, hex: hex, loaded: false }
                    choices_array.push(val) if route.hexes.include?(hex)
                  end
                end
              end
            end
            choices_array
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

          def process_rptla_choose(action)
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
          end

          def unload_good(train)
            train.name = train.name.partition('+')[0] unless train.nil?
          end

          def process_choose(action)
            entity = action.entity
            return process_rptla_choose(action) if action.entity == @game.rptla

            train, hex = get_train_goods_combo(action.choice)

            if hex
              @log << "#{entity.id} attaches good from #{hex.id} to a #{train.name} train"

              attach_good_to_train(train, hex)
            else
              @log << "#{entity.id} remove good from #{train.name} train"
              unload_good(train)
            end
          end

          def process_ship_routes(action)
            entity = action.entity
            goods_shipped = 0
            action.routes.each do |route|
              goods_shipped += @game.goods_on_train(route.train) if route.revenue
            end
            @game.remove_goods_from_rptla(goods_shipped) if goods_shipped.positive? && entity == @game.rptla
            @log << "#{entity.id} ships #{goods_shipped} good to England" if goods_shipped == 1 && entity == @game.rptla
            @log << "#{entity.id} ships #{goods_shipped} goods to England" if goods_shipped > 1 && entity == @game.rptla
          end

          def process_run_routes(action)
            super
            entity = action.entity
            detach_goods(action.routes) unless action.entity == @game.rptla
            process_ship_routes(action) if action.entity == @game.rptla
            @game.route_trains(entity)&.each do |train|
              train.name = train.name.partition('+')[0]
            end
          end

          def round_state
            super.merge({ current_routes: [] })
          end
        end
      end
    end
  end
end
