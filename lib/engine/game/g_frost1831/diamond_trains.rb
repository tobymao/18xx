# frozen_string_literal: true

module Engine
  module Game
    module GFrost1831
      module DiamondTrains
        DIAMOND_TRAINS = {
          '2' => '2◆',
          '3' => '3◆',
          '4' => '4◆',
          '5' => '5◆',
          '6' => '6◆',
          'D' => 'D◆',
        }.freeze

        def diamond_train?(train)
          train.name.include?('◆')
        end

        # Can a corporation upgrade any of its trains to ◆?
        def can_upgrade_to_diamond?(corporation)
          !upgradeable_to_diamond(corporation).empty?
        end

        # Returns array of [train, [available_factions]] pairs for trains that can be upgraded
        def upgradeable_to_diamond(corporation)
          return [] unless @corporation_factions[corporation.id]

          factions = @corporation_factions[corporation.id] || []
          available_factions = factions.select do |f|
            (@corporation_influence[corporation.id]&.dig(f) || 0).positive?
          end
          return [] if available_factions.empty?

          corporation.trains.select { |t| !diamond_train?(t) && DIAMOND_TRAINS[t.name] }.map do |train|
            [train, available_factions]
          end
        end

        # Perform the diamond upgrade: mutate train name, spend 1 influence cube
        def upgrade_train_to_diamond!(corporation, train, faction_sym)
          base_name = train.name
          new_name = DIAMOND_TRAINS[base_name]
          raise GameError, "Cannot upgrade #{base_name} to diamond" unless new_name

          cubes = @corporation_influence[corporation.id]&.dig(faction_sym) || 0
          raise GameError, "#{corporation.name} has no influence with #{faction_display_name(faction_sym)}" unless cubes.positive?

          @corporation_influence[corporation.id][faction_sym] -= 1
          @faction_influence[faction_sym] -= 1 if @faction_influence[faction_sym].positive?

          train.name = new_name

          @log << "#{corporation.name} upgrades #{base_name} to #{new_name} "\
                  "(spends 1 influence from #{faction_display_name(faction_sym)})"
        end

        # Corporations with ◆ trains use a no-blocking graph for ROUTES ONLY
        # For tile laying, always use the normal blocking graph
        def graph_for_entity(entity)
          if entity.is_a?(Engine::Corporation) &&
             entity.type != :faction &&
             entity.trains.any? { |t| diamond_train?(t) }
            @no_blocking_graph
          else
            @graph
          end
        end

        # For tile laying, always use the normal graph (tokens block)
        # Diamond trains only bypass blocking for running routes, not for laying track
        def tile_lay_graph_for_entity(_entity)
          @graph
        end

        # Diamond trains can bypass cities blocked by supported factions
        def check_connected(route, corporation)
          train = route.train
          if diamond_train?(train)
            supported_factions = @corporation_factions[corporation.id] || []
            supported_faction_corps = supported_factions.map { |sym| @corporations.find { |c| c.id == sym } }.compact

            route.ordered_paths.each_cons(2) do |a, b|
              unless diamond_connects?(a, b, corporation, supported_faction_corps)
                raise GameError, 'Route is not connected'
              end
            end
          else
            super
          end
        end

        def diamond_connects?(path_a, path_b, corporation, supported_faction_corps)
          return true if path_a.connects_to?(path_b, corporation)

          [path_a.a, path_a.b].each do |part|
            next unless part.respond_to?(:blocks?) && part.city?
            next unless path_b.nodes.include?(part)

            return true if city_blocked_only_by_factions?(part, corporation, supported_faction_corps)
          end

          false
        end

        def city_blocked_only_by_factions?(city, corporation, supported_faction_corps)
          return false if city.tokened_by?(corporation)
          return false if city.tokens.include?(nil)

          city.tokens.compact.any? do |token|
            supported_faction_corps.include?(token.corporation)
          end
        end
      end
    end
  end
end
