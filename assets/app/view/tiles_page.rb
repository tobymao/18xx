# frozen_string_literal: true

require 'game_manager'
require 'lib/connection'
require 'engine/test_tiles'
require 'lib/params'
require 'view/tiles'

module View
  class TilesPage < Tiles
    include GameManager

    needs :route
    needs :fixture_data, default: {}, store: true

    ROUTE_FORMAT = %r{/tiles/([^/?]*)(?:/([^?]+))?}.freeze

    TILE_IDS = [
      Engine::Tile::WHITE.keys,
      Engine::Tile::YELLOW.keys,
      Engine::Tile::GREEN.keys,
      Engine::Tile::BROWN.keys,
      Engine::Tile::GRAY.keys,
      Engine::Tile::RED.keys,
    ].flatten

    def render
      match = @route.match(ROUTE_FORMAT)
      dest = match[1]
      hexes_or_tiles = match[2]

      layout = (Lib::Params['l'] || 'flat').to_sym

      # parse URL params 'r' and 'n'; but don't apply them to /tiles/all, are
      # you trying to kill your browser?
      @rotations =
        case (r = Lib::Params['r'])
        when nil
          [0]
        when 'all'
          Engine::Tile::ALL_EDGES
        else
          r.split.map(&:to_i)
        end
      @location_name = Lib::Params['n']

      # all common hexes/tiles
      if dest == 'all'
        h('div#tiles', [
            h('div#all_tiles', [
                h(:h2, 'Generic Map Hexes and Common Track Tiles'),
                *TILE_IDS.flat_map { |t| render_tile_blocks(t, layout: layout) },
              ]),

          ])

      elsif dest == 'test'

        render_test_tiles

      elsif dest == 'custom'
        location_name = Lib::Params['n']
        color = Lib::Params['c'] || 'yellow'
        tile = Engine::Tile.from_code(
          'custom',
          color,
          hexes_or_tiles,
          location_name: location_name
        )
        rendered = render_tile_blocks('custom', layout: layout, tile: tile)
        h('div#tiles', rendered)

      # hexes/tiles from a specific game
      elsif hexes_or_tiles
        rendered =
          if hexes_or_tiles == 'all'
            game_titles = dest.split('+')
            game_titles.flat_map do |title|
              next [] unless (game_class = load_game_class(title))

              map_hexes_and_tile_manifest_for(game_class)
            end

          else
            game_title = dest
            hex_or_tile_ids = hexes_or_tiles.split('+')

            if (game_class = load_game_class(game_title))
              players = Array.new(game_class::PLAYER_RANGE.max) { |n| "Player #{n + 1}" }
              game = game_class.new(players)

              [
                h(:h2, game_class.full_title),
                *hex_or_tile_ids.flat_map { |id| render_individual_tile_from_game(game, id) },
              ]
            else
              []
            end
          end

        h('div#tiles', rendered)

      # common tile(s)
      else
        tile_ids_with_rotation = dest.split('+')
        rendered = tile_ids_with_rotation.flat_map do |tile_id_with_rotation|
          id, rotation = tile_id_with_rotation.split('-')
          rotations = rotation ? [rotation.to_i] : @rotations

          render_tile_blocks(
            id,
            layout: layout,
            scale: 3.0,
            rotations: rotations,
            location_name: @location_name,
          )
        end
        h('div#tiles', rendered)
      end
    end

    def render_individual_tile_from_game(game, hex_or_tile_id, scale: 3.0, **kwargs)
      id, rotation = hex_or_tile_id.split('-')
      rotations = rotation ? [rotation.to_i] : @rotations

      # TODO?: handle case with big map and uses X for game-specific tiles
      # (i.e., "X1" is the name of a tile *and* a hex)
      tile, name, hex_coordinates =
        if game.class::TILES.include?(id)
          t = game.tile_by_id("#{id}-0")
          [t, t.name, nil]
        else
          t = game.hex_by_id(id).tile
          [t, id, id]
        end

      render_tile_blocks(
        name,
        layout: game.class::LAYOUT,
        tile: tile,
        location_name: tile.location_name || @location_name,
        scale: scale,
        rotations: rotations,
        hex_coordinates: hex_coordinates,
        **kwargs,
      )
    end

    def map_hexes_and_tile_manifest_for(game_class)
      players = Array.new(game_class::PLAYER_RANGE.max) { |n| "Player #{n + 1}" }
      game = game_class.new(players)

      # map_tiles: hash; key is hex ID, value is the Tile there
      map_tiles = game.hexes.to_h { |h| [h.name, h.tile] }

      # get mapping of tile -> all hex coordinates using that tile
      tile_to_coords = {}
      map_tiles.each do |coord, tile|
        tile_key = tile_to_coords.keys.find do |k|
          [
            k.name == tile.name,
            k.location_name == tile.location_name,
            k.blockers == tile.blockers,
            k.cities.map(&:reservations) == tile.cities.map(&:reservations),
          ].all?
        end
        if tile_key.nil?
          tile_to_coords[tile] = [coord]
        else
          tile_to_coords[tile_key] << coord
        end
      end

      # truncate "names" (list of hexes with this tile)
      map_hexes = tile_to_coords.map do |tile, coords|
        name = coords.join(',')
        name = "#{name.slice(0, 10)}..." if name.size > 13
        tile.name = name
        tile
      end

      rendered_map_hexes = map_hexes.sort.flat_map do |tile|
        render_tile_blocks(
          tile.name,
          layout: game.layout,
          tile: tile,
          location_name: tile.location_name,
          hex_coordinates: tile.name,
        )
      end

      all_tiles = game.tiles.sort.group_by(&:name)
      rendered_tiles =
        if game.tile_groups.empty?
          all_tiles.flat_map do |name, tiles_|
            render_tile_blocks(
              name,
              layout: game.layout,
              tile: tiles_.first,
              num: tiles_.size,
              rotations: @rotations,
              location_name: @location_name,
            )
          end
        else
          game.tile_groups.flat_map do |group|
            if group.one?
              name = group.first
              render_tile_blocks(
                name,
                layout: game.layout,
                tile: all_tiles[name].first,
                num: all_tiles[name].size,
                rotations: @rotations,
                location_name: @location_name,
              )
            else
              name_a, name_b = group
              tile_a = all_tiles[name_a].first
              tile_b = all_tiles[name_b].first
              render_tile_sides(
                name_a,
                name_b,
                layout: game.layout,
                tile_a: tile_a,
                tile_b: tile_b,
                num: all_tiles[name_a].size
              )
            end
          end
        end

      h("div#hexes_and_tiles_#{game_class.title}", [
          h(:h2, game_class.full_title),
          h("div#game_tiles_#{game_class.title}", [
              h(:h3, "#{game_class.title} Tile Manifest"),
              *rendered_tiles,
            ]),
          h("div#map_hexes_#{game_class.title}", [
              h(:h3, "#{game_class.title} Map Hexes"),
              *rendered_map_hexes,
            ]),
          render_toggle_button,
        ])
    end

    def render_toggle_button
      toggle = lambda do
        toggle_setting(@hide_tile_names)
        update
      end

      h(:div, [
        h(:'button.small', { on: { click: toggle } }, "Tile Names #{setting_for(@hide_tile_names) ? '❌' : '✅'}"),
      ])
    end

    def render_test_tiles
      # see /lib/engine/test_tiles.rb
      test_tiles = Engine::TestTiles::TEST_TILES

      scale = 2.0

      return h(:div, [h(:p, 'Loading...')]) unless @connection

      rendered_test_tiles = []

      test_tiles.each do |title, fixtures|
        if title
          game_class = load_game_class(title)
        else
          fixtures[nil][nil].each do |hex_or_tile, opts|
            %i[flat pointy].each do |layout_|
              rendered_test_tiles.concat(
                render_tile_blocks(hex_or_tile, layout: layout_, scale: scale, rotations: @rotations, **opts)
              )
            end
          end
          next
        end

        fixtures.each do |fixture, actions|
          if fixture
            if @fixture_data[fixture]
              actions.each do |action, hex_or_tiles|
                kwargs = action ? { at_action: action } : {}

                game = Engine::Game.load(@fixture_data[fixture], **kwargs)

                hex_or_tiles.each do |hex_or_tile, opts|
                  hex_coordinates = hex_or_tile
                  tile = game.hex_by_id(hex_coordinates).tile

                  rendered_test_tiles.concat(
                    render_tile_blocks(
                      hex_coordinates,
                      layout: game_class::LAYOUT,
                      tile: tile,
                      location_name: tile.location_name,
                      location_on_plain: true,
                      scale: scale,
                      rotations: [tile.rotation],
                      hex_coordinates: hex_coordinates,
                      name_prefix: title,
                      top_text: "#{title}: #{hex_or_tile}",
                      fixture_id: fixture,
                      fixture_title: title,
                      action: action,
                      **opts,
                    )
                  )
                end
              end

            elsif @connection
              # load the fixture game data
              @connection.get("/fixtures/#{title}/#{fixture}.json", '') do |data|
                @fixture_data[fixture] = data
                store(:fixture_data, @fixture_data, skip: false)
              end

              # render placeholder tiles which will be replaced once the
              # appropriate fixture is loaded and processed
              actions.each do |action, hex_or_tiles|
                hex_or_tiles.each do |hex_or_tile, opts|
                  rendered_test_tiles.concat(
                    render_tile_blocks(
                      'blank',
                      layout: game_class::LAYOUT,
                      location_name: 'Loading Fixture...',
                      location_on_plain: true,
                      scale: scale,
                      name_prefix: title,
                      top_text: "#{title}: #{hex_or_tile}",
                      fixture_id: fixture,
                      fixture_title: title,
                      action: action,
                      **opts
                    )
                  )
                end
              end
            end

          else
            players = Array.new(game_class::PLAYER_RANGE.max) { |n| "Player #{n + 1}" }
            game = game_class.new(players)
            actions[nil].each do |hex_or_tile, opts|
              rendered_test_tiles.concat(
                Array(render_individual_tile_from_game(game, hex_or_tile, scale: scale, top_text: "#{title}: #{hex_or_tile}",
                                                                          **opts))
              )
            end
          end
        end
      end

      h('div#tiles', rendered_test_tiles)
    end
  end
end
