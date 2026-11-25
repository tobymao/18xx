# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      FerryLeg = Struct.new(:units, :nodes) do
        def areas
          nil
        end
      end

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

        def areas
          return if @kind == :ferry

          @areas ||= @game.sea_crossing_areas(@from, @to, @units)
        end

        def sea_hex?(hex)
          !!@game.sea_zone(hex.id)
        end

        def channel_passage_cost
          @game.sea_channel_passage_cost
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
