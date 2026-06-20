# frozen_string_literal: true

require 'lib/hex'
require_relative '../game_class_loader'

module View
  # A minimal drag-and-drop editor for authoring the white/blue hexes of a
  # game's map. Draws its own SVG hex grid (reusing the engine's hex geometry so
  # positions line up with the real map) and emits a HEXES snippet for map.rb.
  #
  # Route: /map_editor/<game_title> auto-loads that game's map to edit; bare
  # /map_editor opens a small blank grid.
  #
  # Editor state lives in a class-level state hash rather than in needs/ivars:
  # Snabberb recreates component instances on every render, and needs-backed
  # ivars are not reliably repopulated inside event handlers, so a plain
  # class-level hash is the robust place to keep mutable editor state.
  class MapEditorPage < Snabberb::Component
    include GameClassLoader

    needs :route

    ROUTE_FORMAT = %r{/map_editor/?([^/?]*)}.freeze

    # small blank grid (a 7-hex flower) shown when no game is given
    DEFAULT_FLOWER = [[1, 2], [1, 4], [0, 3], [0, 1], [1, 0], [2, 1], [2, 3]].freeze

    SIZE = 100
    LAYOUT = {
      flat: [SIZE * 3 / 2, SIZE * Math.sqrt(3) / 2],
      pointy: [SIZE * Math.sqrt(3) / 2, SIZE * 3 / 2],
    }.freeze
    MARGIN = 2 # extra rings of empty candidate hexes around a game's map
    MAX_MARGIN = 128 # cap on cols/rows growth so the grid can't get unwieldy
    SCALE = 0.42

    LETTERS = (('A'..'Z').to_a + ('AA'..'AZ').to_a).freeze

    TOOL_COLORS = { 'white' => :white, 'blue' => :blue }.freeze

    # Cap the per-session undo history. Each entry is a full snapshot of the
    # paint state, so keeping an unbounded stack would grow session memory the
    # longer someone edits; 20 steps is plenty for interactive undo.
    UNDO_LIMIT = 20

    # Editor state, lazily initialised per class (not a mutable constant). All
    # instances share it via #state, which keeps it stable across the fresh
    # component instances Snabberb builds on each render.
    def self.state
      @state ||= {
        paint: nil,             # { 'C4' => 'white', ... } or nil before init
        tool: 'white',          # 'white' | 'blue' | 'empty'
        dragging: false,
        stroke_snapshotted: false, # whether the current stroke already pushed undo
        output: nil,
        title: nil,             # game title (or '') the paint state was built for
        margin_x: MARGIN,       # empty candidate columns added left/right
        margin_y: MARGIN,       # empty candidate rows added above/below
        undo: [],               # stack of prior paint snapshots for this session
      }
    end

    def state
      self.class.state
    end

    def render
      game_title = current_title

      # a game title is optional: with one the map is loaded for editing,
      # without one we show a small blank grid
      game = game_title ? load_game_class(game_title) : nil
      return h(:div, [h(:p, "Loading game: #{game_title}")]) if game_title && !game

      @game = game ? game.new(Array.new(game::PLAYER_RANGE.max) { |n| "Player #{n + 1}" }) : nil

      # initialise when first opening or switching games: a game auto-loads its
      # map, a bare editor starts empty (and tight, with no extra rings)
      key = game_title || ''
      if state[:paint].nil? || state[:title] != key
        state[:paint] = @game ? template_paint : {}
        state[:title] = key
        state[:output] = nil
        state[:undo] = []
        state[:margin_x] = @game ? MARGIN : 0
        state[:margin_y] = @game ? MARGIN : 0
      end

      h(:div, {
          on: {
            mouseup: lambda { |_e|
              state[:dragging] = false
              state[:stroke_snapshotted] = false
            },
          },
        }, [
          h(:h2, game ? "Map Editor: #{game.full_title}" : 'Map Editor'),
          render_toolbar,
          render_grid,
          render_output,
        ])
    end

    def render_toolbar
      tool_button = lambda do |tool, label|
        active = state[:tool] == tool
        props = {
          style: {
            margin: '0 6px 0 0',
            padding: '6px 12px',
            cursor: 'pointer',
            border: active ? '2px solid #4ea1ff' : '1px solid #888',
            borderRadius: '5px',
          },
          on: {
            click: lambda { |_e|
              state[:tool] = tool
              update
            },
          },
        }
        h(:button, props, label)
      end

      step_button = lambda do |label, key, delta|
        h(:button, {
            style: { margin: '0 2px', padding: '6px 10px', cursor: 'pointer' },
            on: {
              click: lambda { |_e|
                state[key] = clamp_margin((state[key] || MARGIN) + delta)
                update
              },
            },
          }, label)
      end
      axis_control = lambda do |name, key|
        [
          h(:span, { style: { marginLeft: '6px', marginRight: '4px' } }, name),
          step_button.call('−', key, -1),
          h(:input, {
              attrs: { type: 'number', min: 0, max: MAX_MARGIN },
              props: { value: (state[key] || MARGIN).to_s },
              style: { width: '52px', margin: '0 2px', padding: '4px', textAlign: 'center' },
              on: { change: ->(e) { set_margin(key, e) } },
            }),
          step_button.call('+', key, 1),
        ]
      end

      h(:div, { style: { margin: '0.5rem 0' } }, [
          h(:span, { style: { marginRight: '8px' } }, 'Tool:'),
          tool_button.call('white', 'White'),
          tool_button.call('blue', 'Blue'),
          tool_button.call('empty', 'Erase'),
          h(:span, { style: { margin: '0 8px' } }, '|'),
          *axis_control.call('Cols ↔', :margin_x),
          *axis_control.call('Rows ↕', :margin_y),
          h(:span, { style: { margin: '0 8px' } }, '|'),
          h(:button, {
              style: { marginRight: '6px', padding: '6px 12px', cursor: 'pointer' },
              on: { click: ->(_e) { generate_output } },
            }, 'Generate Ruby'),
          h(:button, {
              style: { marginRight: '6px', padding: '6px 12px', cursor: 'pointer' },
              on: { click: ->(_e) { clear! } },
            }, 'Clear'),
          undo_button,
          h(:span, { style: { marginLeft: '12px', color: '#888' } },
            'Click or drag to paint. Drag with Erase to remove.'),
        ])
    end

    def undo_button
      disabled = (state[:undo] || []).empty?
      h(:button, {
          attrs: { disabled: disabled },
          style: {
            marginRight: '6px',
            padding: '6px 12px',
            cursor: disabled ? 'default' : 'pointer',
            opacity: disabled ? 0.5 : 1,
          },
          on: { click: ->(_e) { undo } },
        }, 'Undo')
    end

    def render_grid
      cells = candidate_cells
      tx, ty = LAYOUT[@layout]
      width = ((tx * ((@max_x - @min_x) + 2)) + (SIZE * 2)) * SCALE
      height = ((ty * ((@max_y - @min_y) + 2)) + (SIZE * 2)) * SCALE

      nodes = cells.map { |coord, xy| hex_node(coord, xy[0], xy[1]) }

      h(:div, { style: { overflow: 'auto', border: '1px solid #444', margin: '0.5rem 0' } }, [
          h(:svg, { attrs: { width: width.round.to_s, height: height.round.to_s } }, [
              h(:g, { attrs: { transform: "scale(#{SCALE})" } }, nodes),
            ]),
        ])
    end

    def hex_node(coord, x, y)
      tx, ty = LAYOUT[@layout]
      px = (tx * (x - @min_x + 1)) + SIZE
      py = (ty * (y - @min_y + 1)) + SIZE
      color = (state[:paint] || {})[coord]
      fill =
        if (sym = TOOL_COLORS[color])
          Lib::Hex::COLOR[sym]
        else
          '#2b2b2b' # empty candidate hex
        end
      rot = @layout == :pointy ? ' rotate(30)' : ''

      props = {
        attrs: {
          transform: "translate(#{px}, #{py})#{rot}",
          fill: fill,
          stroke: 'black',
          'stroke-width': 1,
          cursor: 'pointer',
        },
        on: {
          click: ->(_e) { paint(coord) },
          mousedown: ->(_e) { start_paint(coord) },
          mouseover: ->(_e) { drag_paint(coord) },
        },
      }

      h(:g, props, [
          h(:polygon, attrs: { points: Lib::Hex::POINTS }),
          h(:text, {
              attrs: {
                'text-anchor': 'middle',
                y: 10,
                'font-size': 30,
                fill: color ? '#0009' : '#888',
                'pointer-events': 'none',
              },
            }, coord),
        ])
    end

    def render_output
      output = state[:output]
      return h(:div) unless output

      h(:div, { style: { margin: '0.5rem 0' } }, [
          h(:p, 'Paste into the game\'s map.rb (HEXES):'),
          h(:textarea, {
              attrs: { readonly: true, spellcheck: false },
              style: { width: '100%', height: '260px', fontFamily: 'monospace', fontSize: '12px' },
            }, output),
        ])
    end

    # --- painting ---------------------------------------------------------

    def start_paint(coord)
      state[:dragging] = true
      state[:stroke_snapshotted] = false # new stroke: allow one fresh snapshot
      paint(coord)
    end

    def drag_paint(coord)
      paint(coord) if state[:dragging]
    end

    def paint(coord)
      current = state[:paint] || {}
      old = current[coord]
      new_color = state[:tool] == 'empty' ? nil : state[:tool]
      return if old == new_color # re-painting a hex its current color is not an event

      snapshot_stroke! # one undo step per stroke, taken before the first change
      state[:paint] = current
      if new_color.nil?
        current.delete(coord)
      else
        current[coord] = new_color
      end
      update
    end

    # snapshot once per stroke, the first time a hex actually changes
    def snapshot_stroke!
      return if state[:stroke_snapshotted]

      snapshot!
      state[:stroke_snapshotted] = true
    end

    def snapshot!
      state[:undo] ||= []
      state[:undo].push((state[:paint] || {}).dup)
      state[:undo].shift while state[:undo].size > UNDO_LIMIT
    end

    def undo
      stack = state[:undo] || []
      return if stack.empty?

      state[:paint] = stack.pop
      state[:output] = nil
      update
    end

    def clear!
      return if (state[:paint] || {}).empty?

      snapshot!
      state[:paint] = {}
      state[:output] = nil
      update
    end

    # --- state / geometry -------------------------------------------------

    def clamp_margin(value)
      [[value, 0].max, MAX_MARGIN].min
    end

    # set a cols/rows margin from the number input, validating integer input:
    # keep digits only, default empty to 0, and clamp to 0..MAX_MARGIN
    def set_margin(key, event)
      raw = event.JS['target'].JS['value'].to_s
      digits = raw.gsub(/[^0-9]/, '')
      state[key] = clamp_margin(digits.empty? ? 0 : digits.to_i)
      update
    end

    def current_title
      t = @route.match(ROUTE_FORMAT)[1]
      t.nil? || t.empty? ? nil : t
    end

    # the game's current white/blue hexes, used to auto-load its map for editing
    def template_paint
      paint = {}
      return paint unless @game

      @game.hexes.each do |hex|
        next if hex.empty

        case hex.tile&.color
        when :white then paint[hex.id] = 'white'
        when :blue then paint[hex.id] = 'blue'
        end
      end
      paint
    end

    # all coords to draw: a parity-matching blank grid sized to the game's map
    # (or the default flower with no game) plus the margin rings. The bounds come
    # only from the base map + margin, NOT from painted hexes, so painting in the
    # outer ring does not grow the canvas — use the cols/rows margin to resize.
    def candidate_cells
      @layout = @game && @game.layout == :pointy ? :pointy : :flat

      base =
        if @game
          @game.hexes.reject(&:empty).map { |hex| [hex.x, hex.y] }
        else
          DEFAULT_FLOWER
        end
      base = [[0, 0]] if base.empty?

      xs = base.map { |xy| xy[0] }
      ys = base.map { |xy| xy[1] }

      mx = state[:margin_x] || MARGIN
      my = state[:margin_y] || MARGIN
      @min_x = [xs.min - mx, 0].max
      @max_x = xs.max + mx
      @min_y = [ys.min - my, 0].max
      @max_y = ys.max + my

      ref = base.first
      parity = (ref[0] + ref[1]).even?

      cells = {}
      (state[:paint] || {}).each_key { |c| cells[c] = parse_coord(c) }
      (@min_x..@max_x).each do |x|
        (@min_y..@max_y).each do |y|
          next unless (x + y).even? == parity

          coord = LETTERS[x] + (y + 1).to_s
          cells[coord] ||= [x, y]
        end
      end
      cells
    end

    def parse_coord(coord)
      m = coord.match(/([A-Z]+)(-?\d+)/)
      return [0, 0] unless m

      [LETTERS.index(m[1]) || 0, m[2].to_i - 1]
    end

    # --- output -----------------------------------------------------------

    def generate_output
      by_color = { 'white' => [], 'blue' => [] }
      (state[:paint] || {}).each { |coord, color| by_color[color] << coord if by_color[color] }

      blocks = %w[white blue].map { |color| format_group(color, by_color[color]) }
      state[:output] = blocks.join("\n")
      update
    end

    def format_group(color, coords)
      sorted = coords.sort_by { |c| parse_coord(c) }
      if sorted.empty?
        "#{color}: {\n          },"
      else
        rows = sorted.each_slice(10).map { |slice| '            ' + slice.join(' ') }
        "#{color}: {\n          %w[\n#{rows.join("\n")}\n] => '',\n          },"
      end
    end
  end
end
