# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1840
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.corporation? || entity.type == :major

            base = super.dup

            if entity.type == :minor && !entity.trains.empty?
              base << 'run_routes' if base.empty?
              base << 'scrap_train'
            end
            base
          end

          def auto_actions(entity)
            return unless entity.type == :city

            start_nodes = @game.starting_nodes(entity)

            route_1 = route_for_node(entity, start_nodes[0])
            route_2 = route_for_node(entity, start_nodes[1])
            puts route_1.connection_hexes
            puts route_2.connection_hexes

            route = if !route_1.connection_hexes.empty? && route_2.connection_hexes.empty?
                      route_1
                    elsif route_1.connection_hexes.empty? && !route_2.connection_hexes.empty?
                      route_2
                    else
                      route_1.revenue > route_2.revenue ? route_1 : route_2
                    end

            [Engine::Action::RunRoutes.new(
              entity,
              routes: [route],
            )]

            #     "train": "City-1",
            #   "connections": [
            #     [
            #       "A17",
            #       "A15",
            #       "A13"
            #     ]
            #   ],
            #   "hexes": [
            #     "A13",
            #     "A17"
            #   ],
            #   "revenue": 70,
            #   "revenue_str": "A13-A17"
            # }
          end

          def route_for_node(entity, start_node)
            route = Engine::Route.new(
              @game,
              @game.phase,
              entity.trains.first,
            )

            node_visited = []
            start_node.walk(corporation: entity, skip_track: :broad) do |path, _, _|
              next if path.nodes.empty? || node_visited.include?(path.nodes.first)

              route.touch_node(path.nodes.first)
              node_visited << path.nodes.first
            end

            route
          end

          def log_skip(entity)
            @log << "#{entity.name} skips #{description.downcase}" unless entity.type == :major
          end

          def scrappable_trains(entity)
            return [] if entity.type != :minor

            @game.scrappable_trains(entity)
          end

          def scrap_info(train)
            @game.scrap_info(train)
          end

          def scrap_button_text(_train)
            @game.scrap_button_text
          end

          def process_scrap_train(action)
            @game.scrap_train(action.train, action.entity)
          end
        end
      end
    end
  end
end
