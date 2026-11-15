# frozen_string_literal: true

module Lib
  class SeaCrossingPath
    CLEARANCE = 3
    COAST_COST = 2

    @instances = {}

    def self.for(game)
      @instances[game] ||= new(game.hexes)
    end

    def initialize(hexes)
      @hexes = hexes
      @paths = {}
      @straightened = {}
    end

    def path(from_hex, to_hex, crossing)
      forward = (from_hex.id <=> to_hex.id) <= 0
      first, last = forward ? [from_hex, to_hex] : [to_hex, from_hex]
      found = (@paths[[first.id, last.id]] ||= cheapest_path(first, last, crossing))
      forward ? found : found.reverse
    end

    def straighten(hexes, crossing)
      forward = (hexes.first.id <=> hexes.last.id) <= 0
      canonical = forward ? hexes : hexes.reverse
      straight = (@straightened[canonical.map(&:id)] ||= straighten_path(canonical, crossing))
      forward ? straight : straight.reverse
    end

    private

    def land_distance(hex, crossing)
      @land_distance ||= begin
        distance = {}
        land = @hexes.reject { |h| crossing.sea_hex?(h) }
        edge = @hexes.select { |h| crossing.sea_hex?(h) && h.all_neighbors.size < 6 }
        land.each { |h| distance[h] = 0 }
        edge.each { |h| distance[h] = 1 }
        queue = land + edge
        until queue.empty?
          current = queue.shift
          current.all_neighbors.each_value do |neighbor|
            next if distance.key?(neighbor)

            distance[neighbor] = distance[current] + 1
            queue << neighbor
          end
        end
        distance
      end
      @land_distance[hex] || @hexes.size
    end

    def step_cost(hex, crossing)
      return crossing.channel_passage_cost unless crossing.sea_hex?(hex)

      shortfall = [self.class::CLEARANCE - land_distance(hex, crossing), 0].max
      1 + (self.class::COAST_COST * shortfall)
    end

    def cheapest_path(from_hex, to_hex, crossing)
      costs = { from_hex => 0 }
      previous = {}
      frontier = [from_hex]
      done = {}
      until frontier.empty?
        current = frontier.min_by.with_index { |hex, index| [costs[hex], index] }
        frontier.delete(current)
        next if done[current]

        done[current] = true
        break if current == to_hex

        current.all_neighbors.each_value do |neighbor|
          cost = costs[current] + step_cost(neighbor, crossing)
          next if costs[neighbor] && costs[neighbor] <= cost

          costs[neighbor] = cost
          previous[neighbor] = current
          frontier << neighbor
        end
      end
      found = [to_hex]
      found.unshift(previous[found.first]) while previous[found.first]
      found
    end

    def straighten_path(path, crossing)
      allowed = path.to_h { |hex| [hex, true] }
      result = [path.first]
      index = 0
      while index < path.size - 1
        jump = (path.size - 1).downto(index + 1).find do |candidate|
          line = line_hexes(path[index], path[candidate])
          next unless line.all? { |hex| hex && (crossing.sea_hex?(hex) || allowed[hex]) }

          line.map { |hex| land_distance(hex, crossing) }.min >=
            path[index..candidate].map { |hex| land_distance(hex, crossing) }.min
        end
        index = jump || (index + 1)
        result << path[index]
      end
      result
    end

    def line_hexes(from_hex, to_hex)
      dq = grid_q(to_hex) - grid_q(from_hex)
      dr = to_hex.y - from_hex.y
      steps = ((dq.abs + dr.abs + (dq + dr).abs) / 2.0).round
      return [from_hex] if steps.zero?

      (0..steps).map do |k|
        t = k / steps.to_f
        hex_at_cube(grid_q(from_hex) + (dq * t) + 1e-6, from_hex.y + (dr * t) + 1e-6)
      end
    end

    def grid_parity
      @grid_parity ||= (@hexes.first.x - @hexes.first.y) % 2
    end

    def grid_q(hex)
      (hex.x - hex.y - grid_parity) / 2.0
    end

    def hex_by_grid
      @hex_by_grid ||= @hexes.to_h { |hex| [[hex.x, hex.y], hex] }
    end

    def hex_at_cube(q, r)
      s = -q - r
      rq = q.round
      rr = r.round
      rs = s.round
      dq = (rq - q).abs
      dr = (rr - r).abs
      ds = (rs - s).abs
      if dq > dr && dq > ds
        rq = -rr - rs
      elsif dr > ds
        rr = -rq - rs
      end
      hex_by_grid[[(2 * rq) + rr + grid_parity, rr]]
    end
  end
end
