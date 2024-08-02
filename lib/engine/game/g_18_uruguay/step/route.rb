# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18Uruguay
      module Step
        class Route < Engine::Step::Route
          def setup
            @round.current_routes = {}
          end

          def actions(entity)
            return [] if entity == @game.rptla
            return [] if !entity.operator? || @game.route_trains(entity).empty? || !@game.can_run_route?(entity)
            return [] if entity.minor?

            actions = ACTIONS.dup
            actions << 'choose' if choosing?(entity)
            actions
          end

          def choosing?(_entity)
            true
          end

          def log_skip(entity)
            return if entity.minor?
            return if entity == @game.rptla

            super
          end

          def choice_name
            return '' if @game.nationalized?
            return 'Attach goods to ships' if current_entity == @game.rptla

            'Attach good to a train'
          end

          def goods_hexes
            @game.hexes.select do |hex|
              hex.assignments.keys.find { |a| a.include? 'GOODS' }
            end
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
            choices
          end

          def route_for_train(train)
            @round.current_routes[train] unless train.nil?
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

          def process_choose(action)
            entity = action.entity

            train, hex = get_train_goods_combo(action.choice)

            if hex
              @log << "#{entity.id} attaches good from #{hex.id} to a #{train.name} train"

              @game.attach_good_to_train(train, hex)
            else
              @log << "#{entity.id} remove good from #{train.name} train"
              @game.unload_good(train)
            end
          end

          def detach_goods(routes)
            routes.each do |route|
              train = route.train
              next unless @game.train_with_goods?(train)

              hex = @game.good_pickup_hex(train)
              good = hex.assignments.keys.find { |a| a.include? 'GOODS' }
              @game.unload_good(train)
              raise NoToken, "No good token found at Hex #{hex&.id}" if good.nil?
              raise NoToken, "Hex #{hex&.id} is not included in route for train #{train.name}" unless route.hexes.include?(hex)

              hex.remove_assignment!(good)
              @log << "#{current_entity.id} moves a good to the harbor"
              @game.add_good_to_rptla unless good.nil?
            end
          end

          def process_run_routes(action)
            super
            entity = action.entity
            detach_goods(action.routes) unless action.entity == @game.rptla
            @game.route_trains(entity)&.each do |train|
              @game.unload_good(train)
            end
          end

          def round_state
            super.merge({ current_routes: {} })
          end
        end
      end
    end
  end
end
