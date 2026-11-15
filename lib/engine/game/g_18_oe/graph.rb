# frozen_string_literal: true

require_relative '../../graph'
require_relative 'sea_network'

module Engine
  module Game
    module G18OE
      class Graph < Engine::Graph
        def initialize(game, **opts)
          @sea_networks = {}
          super
        end

        def clear
          super
          @sea_networks.clear
        end

        def sea_network(corporation)
          @sea_networks[corporation] ||= SeaNetwork.new(@game, corporation)
        end

        def extra_root_hexes(corporation)
          super.merge(sea_network(corporation).landings) { |_, first, second| first.merge(second) }
        end

        def extra_root_nodes(corporation)
          super.merge(sea_network(corporation).landing_nodes.to_h { |node| [node, true] })
        end

        def compute(corporation, **opts, &block)
          result = super
          reachable = @reachable_hexes[corporation]
          return result if opts[:one_token] || !reachable

          network = sea_network(corporation)
          (network.landing_nodes + network.landing_offboards).each { |node| reachable[node.hex] = true }
          result
        end

        def walk_token(node, skip_paths:, corporation:, links: false, **opts, &block)
          ports = links && corporation ? usable_ports(corporation) : []
          return walk_track(node, skip_paths: skip_paths, corporation: corporation, **opts, &block) if ports.empty?

          walk_with_sea_links(node, ports, skip_paths: skip_paths, corporation: corporation, **opts, &block)
        end

        def can_token?(corporation, **opts)
          super || !landing_tokenable_cities(corporation).empty?
        end

        def tokenable_cities(corporation)
          (super + landing_tokenable_cities(corporation)).uniq
        end

        private

        def walk_track(node, skip_paths:, corporation:, **opts, &block)
          return node.walk(skip_paths: skip_paths, corporation: corporation, **opts, &block) unless @game.wcf_placeholder

          lille = @game.lille_city
          walker = proc do |path, visited_paths, visited|
            result = yield(path, visited_paths, visited)
            if result != :abort && path.nodes.include?(lille) && !visited[lille] && @game.wcf_restricted?(corporation)
              ferry_arrival = @game.wcf_path?(path)
              land_paths = ferry_arrival ? [] : lille.paths.reject { |other| @game.wcf_path?(other) }
              lille.walk(**opts.merge(visited: ferry_arrival ? visited : visited.dup,
                                      visited_paths: ferry_arrival ? visited_paths : visited_paths.dup,
                                      corporation: corporation,
                                      skip_paths: (skip_paths || {}).merge(land_paths.to_h { |other| [other, true] }),
                                      counter: Hash.new(0)), &walker)
            end
            result
          end
          opts = opts.merge(pruner: nil) if @game.wcf_restricted?(corporation)
          node.walk(skip_paths: skip_paths, corporation: corporation, **opts, &walker)
        end

        def walk_with_sea_links(node, ports, corporation:, skip_paths:, **opts, &block)
          context = {
            corporation: corporation,
            skip_paths: skip_paths,
            opts: opts,
            block: block,
            network: sea_network(corporation),
            level: @game.largest_train_level(corporation),
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

        def usable_ports(corporation)
          @game.class::PORTS.flat_map do |hex_id, exits|
            exits.keys.select { |exit| @game.port_usable?(hex_id, exit, corporation) }.map { |exit| [hex_id, exit] }
          end
        end

        def root_anchors(node, corporation)
          anchors = @game.port_anchors(node, corporation)
          offshore = [node.hex.id, :offshore]
          anchors << offshore if node.city? && !anchors.include?(offshore) && @game.pathless_ferry_partner(offshore)
          anchors
        end

        def departable?(usable, anchor)
          usable[anchor] || @game.pathless_ferry_partner(anchor)
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
          partner = @game.pathless_ferry_partner(anchor)
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

        def landing_tokenable_cities(corporation)
          sea_network(corporation).landing_nodes.select do |node|
            node.city? && node.tokenable?(corporation, free: true)
          end
        end
      end
    end
  end
end
