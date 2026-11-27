# frozen_string_literal: true

require_relative '../../graph'
require_relative 'graph/sea_connectivity'
require_relative 'graph/sea_link_walk'

module Engine
  module Game
    module G18OE
      class Graph < Engine::Graph
        include SeaLinkWalk

        def initialize(game, **opts)
          @sea_connectivityes = {}
          @corporation_ports = nil
          super
        end

        def clear
          super
          @sea_connectivityes.clear
          @corporation_ports = nil
        end

        def sea_connectivity(corporation)
          @sea_connectivityes[corporation] ||= SeaConnectivity.new(@game, corporation)
        end

        def extra_root_hexes(corporation)
          super.merge(sea_connectivity(corporation).landings) { |_, first, second| first.merge(second) }
        end

        def extra_root_nodes(corporation)
          super.merge(sea_connectivity(corporation).landing_nodes.to_h { |node| [node, true] })
        end

        def compute(corporation, **opts, &block)
          result = super
          reachable = @reachable_hexes[corporation]
          return result if opts[:one_token] || !reachable

          network = sea_connectivity(corporation)
          (network.landing_nodes + network.landing_offboards).each { |node| reachable[node.hex] = true }
          result
        end

        def walk_token(node, skip_paths:, corporation:, links: false, **opts, &block)
          ports = links && corporation ? corporation_ports(corporation) : []
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

        def landing_tokenable_cities(corporation)
          sea_connectivity(corporation).landing_nodes.select do |node|
            node.city? && node.tokenable?(corporation, free: true)
          end
        end
      end
    end
  end
end
