# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module SeaLinkWalk
        private

        def walk_with_sea_links(node, ports, corporation:, skip_paths:, **opts, &block)
          context = {
            corporation: corporation,
            skip_paths: skip_paths,
            opts: opts,
            block: block,
            network: sea_connectivity(corporation),
            level: @game.largest_city_limit(corporation) + @game.sea_pool_total(corporation, @game.phase),
            ports: ports,
            usable: ports.to_h { |anchor| [anchor, true] },
            walkers: {},
            visited: {},
          }
          root_anchors(node, corporation).each do |anchor|
            depart(context, node, anchor, {}, nil) if anchor[1] == :offshore
          end
          walk_token(node, visited: context[:visited], corporation: corporation, skip_paths: skip_paths, **opts,
                     &sea_walker(context, nil))
        end

        def corporation_ports(corporation)
          @corporation_ports ||= {}
          @corporation_ports[corporation] ||= @game.class::PORTS.flat_map do |hex_id, exits|
            exits.keys.select { |exit| @game.port_usable?(hex_id, exit, corporation) }.map { |exit| [hex_id, exit] }
          end
        end

        def root_anchors(node, corporation)
          anchors = @game.usable_ports(node, corporation)
          offshore = [node.hex.id, :offshore]
          anchors << offshore if node.city? && !anchors.include?(offshore) && @game.offshore_ferry_end(offshore)
          anchors
        end

        def departable?(usable, anchor)
          usable[anchor] || @game.offshore_ferry_end(anchor)
        end

        def sea_walker(context, landing_hex)
          context[:walkers][landing_hex] ||= proc do |path, visited_paths, visited|
            result = context[:block].call(path, visited_paths, visited)
            next result if result == :abort

            usable = context[:usable]
            path.nodes.each do |node|
              hex_id = node.hex.id
              path.exits.each do |exit|
                anchor = [hex_id, exit]
                depart(context, node, anchor, visited_paths, landing_hex, path) if departable?(usable, anchor)
              end
              offshore = [hex_id, :offshore]
              depart(context, node, offshore, visited_paths, landing_hex, path) if !visited[node] && departable?(usable, offshore)
            end
            result
          end
        end

        def depart(context, node, anchor, visited_paths, landing_hex, path = nil)
          level = context[:level]
          if node.hex != landing_hex && context[:usable][anchor]
            context[:ports].each do |target|
              next if target[0] == node.hex.id

              distance = @game.port_distance(anchor, target)
              jump(context, :crossing, node, anchor, target, visited_paths, landing_hex, path) if distance && distance <= level
            end
          end
          partner = @game.offshore_ferry_end(anchor)
          jump(context, :ferry, node, anchor, partner, visited_paths, landing_hex, path) if partner
        end

        def jump(context, kind, node, anchor, target, visited_paths, landing_hex, path)
          visited = context[:visited]
          corporation = context[:corporation]
          context[:network].anchor_nodes(*target).each do |landing|
            next if visited[landing]

            crossing = @game.sea_crossing(kind, anchor, target, [node, landing])
            jump_paths = visited_paths.dup
            jump_paths.delete(path) if path
            jump_paths[crossing] = true
            result = context[:block].call(crossing, jump_paths, visited)
            next if result == :abort || landing.blocks?(corporation)

            marked = !visited[node]
            visited[node] = true if marked
            walker = sea_walker(context, kind == :crossing ? landing.hex : landing_hex)
            walk_token(landing, visited: visited, visited_paths: jump_paths, corporation: corporation,
                                skip_paths: context[:skip_paths], counter: Hash.new(0), **context[:opts], &walker)
            visited.delete(node) if marked
          end
        end
      end
    end
  end
end
