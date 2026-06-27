# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18Cuba
      module Step
        # 18Uruguay-style: while routing, a major attaches wagons and loads on-route sugar cubes (rule VII.9/VII.10/VII.11).
        class Route < Engine::Step::Route
          # setup runs per corporation (next_entity!), so reset both hashes between corps within an OR.
          def setup
            super
            @round.current_routes = {}
            @round.wagon_for_train = {}
          end

          def round_state
            super.merge(current_routes: {}, wagon_for_train: {})
          end

          def actions(entity)
            actions = super
            return actions if actions.empty?

            actions = actions.dup
            actions << 'choose' if choosing?(entity)
            actions
          end

          def choosing?(entity)
            # Keep the choose panel mounted while the entity owns a wagon (route-independent), like 18Uruguay.
            entity.trains.any? { |t| @game.wagon?(t) }
          end

          def choice_name
            'Attach a wagon or load sugar cubes'
          end

          def choices
            choices_for(current_entity)
          end

          # Show the attached wagon on the train in the route UI, e.g. "2+1w" (display only).
          def train_name(_entity, train)
            wagon = @round.wagon_for_train[train.id]
            wagon ? "#{train.name}+#{wagon.name}" : train.name
          end

          def process_choose(action)
            entity = action.entity
            choice = action.choice
            case choice['type']
            when 'attach' then process_attach(entity, choice['wagon'], choice['train'])
            when 'load' then process_load(entity, choice['train'], choice['corp'])
            when 'unload' then process_unload(entity, choice['train'])
            else raise GameError, 'Invalid choice'
            end
          end

          private

          def choices_for(entity)
            wagon_choices(entity).merge(cube_choices(entity))
          end

          def process_attach(entity, wagon_id, train_id)
            wagon = entity.trains.find { |t| t.id == wagon_id }
            train = entity.trains.find { |t| t.id == train_id }
            raise GameError, 'Invalid wagon or train' if wagon.nil? || train.nil?
            raise GameError, 'Train cannot take this wagon' if !@game.wagon?(wagon) || !@game.wagon_attachable?(train)
            raise GameError, 'Wagon or train already attached' if @round.wagon_for_train.key?(train.id) ||
                                                                  @round.wagon_for_train.value?(wagon)

            @round.wagon_for_train[train.id] = wagon
            @log << "#{entity.name} attaches #{wagon.name} to #{train.name}"
          end

          def process_load(entity, train_id, corp_id)
            train = entity.trains.find { |t| t.id == train_id }
            corp = @game.corporation_by_id(corp_id)
            raise GameError, 'Invalid train or mill' if train.nil? || corp.nil?
            raise GameError, 'Train has no wagon' unless @round.wagon_for_train.key?(train.id)
            raise GameError, 'Wagon is full' unless @game.cubes_on_train(train).size < @game.wagon_capacity(train)
            raise GameError, 'No sugar cube available' unless @game.unclaimed_cubes(corp).positive?

            @game.attach_cube_to_train(train, corp)
            @log << "#{entity.name} loads a sugar cube from #{corp.name} onto #{train.name}"
          end

          def process_unload(entity, train_id)
            train = entity.trains.find { |t| t.id == train_id }
            raise GameError, 'Invalid train' unless train

            @game.unload_cubes(train)
            @log << "#{entity.name} unloads the sugar from #{train.name}"
          end

          # Free wagons paired with trains that can still take one (not a wagon, not 4D, none yet).
          def wagon_choices(entity)
            wagons = entity.trains.select { |t| @game.wagon?(t) && !@round.wagon_for_train.value?(t) }
            trains = entity.trains.select { |t| @game.wagon_attachable?(t) && !@round.wagon_for_train.key?(t.id) }
            wagons.each_with_object({}) do |wagon, result|
              trains.each do |train|
                key = { 'type' => 'attach', 'wagon' => wagon.id, 'train' => train.id }
                result[key] = "Attach #{wagon.name} to #{train.name}"
              end
            end
          end

          # Per wagon train at a harbor: "Unload" while it carries cubes, plus a
          # "Load sugar from <mill>" per on-route mill while spare capacity remains.
          def cube_choices(entity)
            result = {}
            entity.trains.each do |train|
              next unless @round.wagon_for_train.key?(train.id)

              route = @round.current_routes[train.id]
              next unless route&.visited_stops&.any? { |s| @game.harbor?(s) }

              if @game.train_with_cubes?(train)
                result[{ 'type' => 'unload', 'train' => train.id }] = "Unload sugar from #{train.name}"
              end

              spare = @game.wagon_capacity(train) - @game.cubes_on_train(train).size
              next unless spare.positive?

              @game.mill_corps_on_route(route).each do |corp|
                next unless @game.unclaimed_cubes(corp).positive?

                key = { 'type' => 'load', 'train' => train.id, 'corp' => corp.id }
                result[key] = "Load sugar from #{corp.name} onto #{train.name}"
              end
            end
            result
          end
        end
      end
    end
  end
end
