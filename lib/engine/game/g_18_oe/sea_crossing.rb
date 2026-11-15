# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      SeaLeg = Struct.new(:units, :nodes)

      class SeaCrossing
        attr_reader :kind, :from, :to, :nodes, :units, :hexes

        def initialize(kind:, from:, to:, nodes:, units:, hexes:, game:)
          @kind = kind
          @from = from
          @to = to
          @nodes = nodes
          @units = units
          @hexes = hexes
          @game = game
        end

        def sea_hexes
          @sea_hexes ||= @game.sea_hex_path(*@hexes)
        end

        def straighten(hexes)
          @game.straighten_sea_hexes(hexes)
        end

        def id
          [@kind.to_s, @from[0], @from[1].to_s, @to[0], @to[1].to_s]
        end

        def path?
          false
        end

        def chain
          { nodes: @nodes, paths: [], hexes: [], id: id, crossing: self }
        end
      end
    end
  end
end
