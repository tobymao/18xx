# frozen_string_literal: true

require_relative '../../graph'

module Engine
  module Game
    module G18OE
      class Graph < Engine::Graph
        def walk_token(node, skip_paths:, corporation:, **opts)
          return super unless @game.wcf_placeholder

          lille = @game.lille_city
          walker = proc do |path, visited_paths, visited|
            result = yield path, visited_paths, visited
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
          super(node, skip_paths: skip_paths, corporation: corporation, **opts, &walker)
        end
      end
    end
  end
end
