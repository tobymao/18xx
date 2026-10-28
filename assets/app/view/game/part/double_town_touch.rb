# frozen_string_literal: true

module View
  module Game
    module Part
      module DoubleTownTouch
        module_function

        def touch_towns(route, towns)
          nodes = route_nodes(route)
          present = towns.select { |town| nodes.include?(town) }

          case present.size
          when 0
            add_both(route, towns)
          when 1
            route.touch_node((towns - present).first)
          else
            remove_both(route, towns, nodes)
          end
        end

        def route_nodes(route)
          data = route.connection_data
          return [route.last_node].compact if data.empty?

          ([data.first[:left]] + data.map { |segment| segment[:right] }).uniq
        end

        def route_ends(route)
          data = route.connection_data
          data.empty? ? [route.last_node].compact : [data.first[:left], data.last[:right]]
        end

        def add_both(route, towns)
          ends = route_ends(route)
          first = towns.find { |town| ends.any? { |node| route.select(node, town).first } } || towns.first
          second = (towns - [first]).first

          route.touch_node(first)
          route.touch_node(second)
          route.touch_node(first) unless route_nodes(route).include?(first)
        end

        def remove_both(route, towns, nodes)
          if towns.include?(nodes[0]) && towns.include?(nodes[1])
            route.touch_node(nodes[1])
            route.touch_node(nodes[2]) if nodes[2]
          elsif towns.include?(nodes[-1]) && towns.include?(nodes[-2])
            2.times { route.touch_node(route.connection_data.last[:right]) }
          else
            return
          end

          route.touch_node(route.last_node) if towns.include?(route.last_node)
        end
      end
    end
  end
end
