# frozen_string_literal: true

require_relative '../operating'
require_relative '../../token'

module Engine
  module Round
    module G1870
      class Operating < Operating
        attr_accessor :river_special_tile_lay, :connection_steps
        attr_reader :connection_runs

        def start_operating
          super

          @river_special_tile_lay = nil
        end

        def setup
          check_connection_runs
          @connection_steps = []

          super
        end

        def next_entity!
          check_connection_runs
          return if @connection_runs.any?

          super
        end

        def active_entities
          return @connection_runs.keys if @connection_runs.any?

          super
        end

        def check_connection_runs
          @connection_runs = {}
          corporations = @game.corporations.dup.sort
          if current_entity && corporations.any?(current_entity)
            corporations.unshift(corporations.delete(current_entity))
          end

          corporations.each do |corporation|
            next unless (bound = corporation.trains.map(&:distance).max)
            next unless (destination = @game.destination_hex(corporation))
            next unless destination.assigned?(corporation)

            home = @game.home_hex(corporation)
            next unless check_connection_run(corporation, bound, home, { destination => 1 }, [])

            corporation.trains.each { |train| train.operated = false }

            @connection_runs[corporation] = destination
            destination.remove_assignment!(corporation)

            @game.log << "-- #{corporation.name} can connect to its destination --"
          end
        end

        def check_connection_run(corporation, bound, home, queue, visited)
          return false unless (current = queue.keys.min_by { |h| home.distance(h) })

          current.all_connections.each do |conn|
            hex = conn.hexes.find { |h| h != current && (h.tile.city_towns + h.tile.offboards).any? }

            return true if hex == home

            next if queue[current] + 1 == bound
            next if visited.include?(hex)
            next if hex.tile.city_towns.all? { |c| c.blocks?(corporation) }

            queue[hex] ||= Float::INFINITY
            queue[hex] = queue[current] + 1 if queue[current] < queue[hex]
          end

          next_queue = queue.reject { |h, _| h == current }
          check_connection_run(corporation, bound, home, next_queue, visited.append(current))
        end
      end
    end
  end
end
