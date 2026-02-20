# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'

module Engine
  module Game
    module G1880Romania
      module Step
        class Track < Engine::Step::Track
          include G1880Romania::Tracker

          def max_exits(tiles)
            # Ignore max exits for city/town option upgrades
            return tiles if tiles.any? { |t| !t.towns.empty? }

            super
          end

          def pay_tile_cost!(entity_or_entities, tile, rotation, hex, spender, cost, extra_cost)
            super

            crossings = @game.instance_variable_get(:@province_crossings)&.delete(hex)
            return unless crossings&.positive?

            income = 20 * crossings
            @game.bank.spend(income, @game.p2.owner)

            @log << "#{@game.p2.owner.name} receives #{@game.format_currency(income)} for province crossing"
          end
        end
      end
    end
  end
end
