# frozen_string_literal: true

require 'view/game/actionable'
require 'lib/settings'

module View
  module Game
    module G2038
      class RouteSelector < Snabberb::Component
        include Actionable
        include Lib::Settings

        needs :game, store: true, default: nil
        needs :g2038_selected_train, store: true, default: nil
        needs :g2038_hex_route, store: true, default: []
        needs :g2038_lock_at, store: true, default: nil
        needs :g2038_explore_pending, store: true, default: nil
        needs :g2038_pickups, store: true, default: [] # confirmed explicit picks [[hex_id, mine_idx], ...]
        needs :g2038_pending_picks, store: true, default: nil # checked items in active pickup dialog
        needs :g2038_explore_count, store: true, default: 0 # number of explorations confirmed this run
        needs :g2038_last_entity, store: true, default: nil

        def render
          current_entity = @game.round.current_entity
          trains = @game.route_trains(current_entity)

          if @g2038_last_entity != current_entity
            cleanup(skip: true)
            store(:g2038_last_entity, current_entity, skip: true)
          end

          store(:g2038_selected_train, trains.first, skip: true) if @g2038_selected_train.nil? && trains.any?

          children = [h(:h3, 'Run Routes')]
          children << render_train_list(trains)
          children << render_route_display

          if @g2038_explore_pending
            undecided = undecided_mines
            if undecided.any?
              # Initialize pending picks with auto-best selection if not yet set.
              if @g2038_pending_picks.nil?
                rem = holds_remaining
                auto = undecided.sort_by { |m| -m[:value] }.first(rem).map { |m| [m[:hex].id, m[:mine_idx]] }
                store(:g2038_pending_picks, auto, skip: true)
              end
              children << render_pickup_dialog(undecided)
            else
              children << render_explore_dialog
            end
          end

          children << render_actions

          h(:div, { key: 'g2038_route_selector', hook: { destroy: -> { cleanup(skip: true) } } }, children.compact)
        end

        private

        # -----------------------------------------------------------------------
        # Train list
        # -----------------------------------------------------------------------

        def render_train_list(trains)
          rows = trains.map do |train|
            selected = train == @g2038_selected_train
            cargo_holds = @game.cargo_holds_for_train(train)

            on_click = lambda do
              unless train == @g2038_selected_train
                store(:g2038_selected_train, train, skip: true)
                store(:g2038_hex_route, [], skip: true)
                store(:g2038_lock_at, nil, skip: true)
                store(:g2038_pickups, [], skip: true)
                store(:g2038_pending_picks, nil, skip: true)
                store(:g2038_explore_count, 0, skip: true)
                store(:g2038_explore_pending, nil)
              end
            end

            style = {
              border: "solid 3px #{selected ? '#333' : '#bbb'}",
              display: 'inline-block',
              cursor: selected ? 'default' : 'pointer',
              margin: '0.1rem',
              padding: '3px 8px',
              backgroundColor: selected ? '#ddeeff' : 'white',
              borderRadius: '3px',
            }

            h(:tr, [
              h('td.middle', [h(:div, { style: style, on: { click: on_click } }, train.name)]),
              h('td.right.middle', { style: { paddingLeft: '0.5rem' } }, "#{train.distance}MP"),
              h('td.right.middle', { style: { paddingLeft: '0.5rem' } },
                "#{cargo_holds} hold#{cargo_holds == 1 ? '' : 's'}"),
            ])
          end

          h(:table, { style: { marginTop: '0.5rem', textAlign: 'left' } }, [
            h(:thead, [h(:tr, [h(:th, 'Ship'), h(:th, 'MP'), h(:th, 'Cargo')])]),
            h(:tbody, rows),
          ])
        end

        # -----------------------------------------------------------------------
        # Route display
        # -----------------------------------------------------------------------

        def render_route_display
          hexes = @g2038_hex_route

          if hexes.empty?
            mp_line = @g2038_selected_train ? " (#{@g2038_selected_train.distance}MP available)" : ''
            return h(:div, { style: { marginTop: '0.5rem', fontStyle: 'italic' } },
                     "Click a base hex to start the route, then click adjacent hexes.#{mp_line}")
          end

          lock_at = @g2038_lock_at

          hex_spans = hexes.map.with_index do |hex, i|
            locked = lock_at && i < lock_at
            explored = !@game.mine_state[hex.id].nil?
            bg =
              if locked
                '#888'
              elsif hex.tile.color == :blue && !explored
                '#6699cc'
              elsif hex.tile.color == :asteroid
                '#2a1a4a'
              else
                '#555'
              end

            style = {
              display: 'inline-block',
              padding: '2px 5px',
              margin: '2px',
              backgroundColor: bg,
              color: 'white',
              borderRadius: '3px',
              fontSize: '11px',
              fontFamily: 'monospace',
            }
            h(:span, { style: style }, hex.id)
          end

          revenue_str =
            if @g2038_selected_train
              begin
                route = build_route(hexes, pickups: @g2038_pickups || [], lock_at: @g2038_lock_at)
                @game.format_revenue_currency(
                  route.revenue(supress_route_token_check: true,
                                suppress_check_route_combination: true)
                )
              rescue Engine::GameError => e
                "(#{e.message})"
              rescue StandardError
                nil
              end
            end

          # MP counter — transitions + exploration penalties already confirmed.
          mp_display = nil
          if @g2038_selected_train
            total_mp = @g2038_selected_train.distance
            used_mp = hexes.each_cons(2).sum { |a, b| a == b ? 0 : 1 } + @g2038_explore_count
            remaining_mp = total_mp - used_mp
            mp_color = if remaining_mp.negative?
                         '#cc2222'
                       elsif remaining_mp.zero?
                         '#cc7700'
                       end
            mp_style = { marginTop: '4px', fontWeight: 'bold' }
            mp_style[:color] = mp_color if mp_color
            mp_display = h('div.small_font', { style: mp_style },
                           "MP: #{remaining_mp} remaining (#{used_mp}/#{total_mp} used)")
          end

          rows = [
            h('div.small_font', { style: { marginBottom: '2px' } }, 'Route:'),
            h(:div, hex_spans),
          ]
          rows << mp_display if mp_display
          rows << h('div.small_font', { style: { marginTop: '4px' } }, "Est. Revenue: #{revenue_str}") if revenue_str

          # Show confirmed pickups
          if (@g2038_pickups || []).any?
            hold_labels = @g2038_pickups.map do |hex_id, mine_idx|
              val = @game.pickup_value(@game.round.current_entity, hex_id, mine_idx)
              h(:span, {
                  style: {
                    display: 'inline-block',
                    margin: '2px',
                    padding: '1px 4px',
                    backgroundColor: '#2a5',
                    color: 'white',
                    borderRadius: '2px',
                    fontSize: '11px',
                  },
                }, "#{hex_id}:$#{val}")
            end
            rows << h('div.small_font', { style: { marginTop: '2px' } },
                      [h(:span, 'Locked picks: '), *hold_labels])
          end

          h(:div, { style: { marginTop: '0.5rem' } }, rows)
        end

        # -----------------------------------------------------------------------
        # Pickup dialog (shown before exploration when undecided mines exist)
        # -----------------------------------------------------------------------

        def render_pickup_dialog(undecided)
          hex = @g2038_explore_pending
          rem = holds_remaining
          pending = @g2038_pending_picks || []
          pending_set = pending.to_set

          # Can explore only if there is at least 1 more MP beyond the entry cost.
          hexes_so_far = @g2038_hex_route
          transitions = hexes_so_far.each_cons(2).sum { |a, b| a == b ? 0 : 1 }
          mp_used_after_entry = transitions + @g2038_explore_count + 1
          can_explore = @g2038_selected_train && mp_used_after_entry < @g2038_selected_train.distance

          rows = undecided.map do |m|
            key = [m[:hex].id, m[:mine_idx]]
            checked = pending_set.include?(key)

            toggle = lambda do
              picks = (@g2038_pending_picks || []).dup
              if checked
                picks.reject! { |p| p == key }
              elsif picks.size < rem
                picks << key
              end
              store(:g2038_pending_picks, picks)
            end

            ore_color = @game.class::ORE_COLORS[m[:ore].to_sym] || '#888'
            ore_badge = h(:span, {
                            style: {
                              display: 'inline-block',
                              width: '16px',
                              height: '16px',
                              lineHeight: '16px',
                              textAlign: 'center',
                              borderRadius: '50%',
                              backgroundColor: ore_color,
                              color: 'white',
                              fontSize: '10px',
                              fontWeight: 'bold',
                              marginRight: '4px',
                              verticalAlign: 'middle',
                            },
                          }, m[:ore])

            checkbox_style = {
              marginRight: '6px',
              cursor: picks_full?(rem, pending, key) ? 'not-allowed' : 'pointer',
            }

            h(:tr, [
              h(:td, [h(:input, {
                          attrs: { type: 'checkbox', checked: checked },
                          style: checkbox_style,
                          on: { click: toggle },
                        })]),
              h(:td, [ore_badge, m[:hex].id]),
              h('td.right', "$#{m[:value]}"),
            ])
          end

          confirm = lambda do
            picks = @g2038_pending_picks || []
            new_pickups = (@g2038_pickups || []) + picks

            # Reveal the tile immediately so the player sees what was found.
            @game.explore_hex!(hex.id) if @game.mine_state[hex.id].nil?

            hexes = @g2038_hex_route.dup
            # lock_at is the index of the explored hex itself — everything before
            # it was explicitly decided; the explored hex and beyond are auto-selected.
            new_lock_at = hexes.size
            hexes << hex
            store(:g2038_pickups, new_pickups, skip: true)
            store(:g2038_pending_picks, nil, skip: true)
            store(:g2038_hex_route, hexes, skip: true)
            store(:g2038_lock_at, new_lock_at, skip: true)
            store(:g2038_explore_count, @g2038_explore_count + 1, skip: true)
            store(:g2038_explore_pending, nil)
          end

          decline = lambda do
            # Confirm any pending picks but enter without exploring.
            picks = @g2038_pending_picks || []
            new_pickups = (@g2038_pickups || []) + picks

            hexes = @g2038_hex_route.dup
            new_lock_at = hexes.size # index where the declined hex will land
            hexes << hex
            store(:g2038_pickups, new_pickups, skip: true)
            store(:g2038_pending_picks, nil, skip: true)
            store(:g2038_hex_route, hexes, skip: true)
            # Only lock the boundary if the user made explicit picks; otherwise
            # leave lock_at unchanged so explored mines remain auto-selectable.
            store(:g2038_lock_at, new_lock_at, skip: true) if picks.any?
            store(:g2038_explore_pending, nil)
          end

          cancel = lambda do
            store(:g2038_pending_picks, nil, skip: true)
            store(:g2038_explore_pending, nil)
          end

          dialog_style = {
            border: "2px solid #{color_for(:font2)}",
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            padding: '0.5rem',
            margin: '0.5rem 0',
            borderRadius: '4px',
          }

          holds_note = "#{rem - pending.size} hold#{rem - pending.size == 1 ? '' : 's'} remaining after selection"

          pickup_buttons = []
          if can_explore
            pickup_buttons << h('button.small', { on: { click: confirm } },
                                "Confirm & Explore #{hex.id} (+1 MP)")
          end
          pickup_buttons << h('button.small', { on: { click: decline } }, 'Enter Without Exploring')
          pickup_buttons << h('button.small', { on: { click: cancel } }, 'Cancel')

          h(:div, { style: dialog_style }, [
            h(:p, { style: { margin: '0 0 0.3rem 0', fontWeight: 'bold' } },
              "Pick up loads before entering #{hex.id}:"),
            h(:p, { style: { margin: '0 0 0.3rem 0', fontSize: '12px' } }, holds_note),
            h(:table, { style: { marginBottom: '0.4rem' } }, [
              h(:thead, [h(:tr, [h(:th), h(:th, 'Mine'), h(:th, 'Value')])]),
              h(:tbody, rows),
            ]),
            h(:div, pickup_buttons),
          ])
        end

        # Simple explore dialog when no undecided mines precede the target.
        def render_explore_dialog
          hex = @g2038_explore_pending

          # Can explore only if there is at least 1 more MP beyond the entry cost.
          hexes_so_far = @g2038_hex_route
          transitions = hexes_so_far.each_cons(2).sum { |a, b| a == b ? 0 : 1 }
          mp_used_after_entry = transitions + @g2038_explore_count + 1
          can_explore = @g2038_selected_train && mp_used_after_entry < @g2038_selected_train.distance

          confirm = lambda do
            @game.explore_hex!(hex.id) if @game.mine_state[hex.id].nil?

            hexes = @g2038_hex_route.dup
            new_lock_at = hexes.size
            hexes << hex
            store(:g2038_hex_route, hexes, skip: true)
            store(:g2038_lock_at, new_lock_at, skip: true)
            store(:g2038_explore_count, @g2038_explore_count + 1, skip: true)
            store(:g2038_explore_pending, nil)
          end

          decline = lambda do
            hexes = @g2038_hex_route.dup
            hexes << hex
            store(:g2038_hex_route, hexes, skip: true)
            store(:g2038_explore_pending, nil)
          end

          cancel = lambda do
            store(:g2038_explore_pending, nil)
          end

          dialog_style = {
            border: "2px solid #{color_for(:font2)}",
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            padding: '0.5rem',
            margin: '0.5rem 0',
            borderRadius: '4px',
          }

          buttons = []
          buttons << h('button.small', { on: { click: confirm } }, 'Confirm Explore (+1 MP)') if can_explore
          buttons << h('button.small', { on: { click: decline } }, 'Enter Without Exploring')
          buttons << h('button.small', { on: { click: cancel } }, 'Cancel')

          h(:div, { style: dialog_style }, [
            h(:p, { style: { margin: '0 0 0.4rem 0' } },
              "Explore #{hex.id}? Exploring costs +1 MP and reveals a random asteroid tile."),
            h(:div, buttons),
          ])
        end

        # -----------------------------------------------------------------------
        # Actions
        # -----------------------------------------------------------------------

        def render_actions
          submit = lambda do
            hexes = @g2038_hex_route
            if hexes.empty?
              store(:flash_opts, { message: 'No route entered. Use Pass to skip routing.' }, skip: false)
              return
            end

            route = build_route(hexes, pickups: @g2038_pickups || [], lock_at: @g2038_lock_at)
            begin
              process_action(Engine::Action::RunRoutes.new(
                @game.current_entity,
                routes: [route],
                extra_revenue: 0,
              ))
              cleanup
            rescue Engine::GameError => e
              store(:flash_opts, { message: e.message }, skip: false)
            end
          end

          clear = lambda do
            lock_at = @g2038_lock_at
            if lock_at
              # Exploration has happened — only clear the unlocked tail.
              store(:g2038_hex_route, @g2038_hex_route.first(lock_at + 1), skip: true)
            else
              store(:g2038_hex_route, [], skip: true)
              store(:g2038_pickups, [], skip: true)
            end
            store(:g2038_pending_picks, nil, skip: true)
            store(:g2038_explore_pending, nil)
          end

          pass_route = lambda do
            process_action(Engine::Action::RunRoutes.new(
              @game.current_entity,
              routes: [],
            ))
            cleanup
          end

          revenue_display =
            if !@g2038_hex_route.empty? && @g2038_selected_train
              begin
                route = build_route(@g2038_hex_route, pickups: @g2038_pickups || [], lock_at: @g2038_lock_at)
                @game.format_revenue_currency(
                  route.revenue(supress_route_token_check: true,
                                suppress_check_route_combination: true)
                )
              rescue Engine::GameError
                '(Invalid)'
              rescue StandardError
                ''
              end
            end

          submit_label = revenue_display ? "Submit (#{revenue_display})" : 'Submit Route'

          h(:div, { style: { marginTop: '0.5rem' } }, [
            h(:button, {
                style: { minWidth: '8rem', marginRight: '0.3rem' },
                on: { click: submit },
              }, submit_label),
            h('button.small', { on: { click: clear } }, 'Clear'),
            h('button.small', { on: { click: pass_route } }, 'Pass'),
          ])
        end

        # -----------------------------------------------------------------------
        # Helpers
        # -----------------------------------------------------------------------

        def build_route(hexes, pickups: [], lock_at: nil)
          Engine::Route.new(
            @game,
            @game.phase,
            @g2038_selected_train,
            routes: [],
            hexes: hexes,
            pickups: pickups,
            lock_at: lock_at,
          )
        end

        # Mines on route hexes that have been explored and not yet explicitly decided.
        def undecided_mines
          return [] unless @g2038_selected_train

          @game.pickable_stops(
            build_route(@g2038_hex_route),
            @g2038_pickups || []
          )
        end

        def holds_remaining
          return 0 unless @g2038_selected_train

          cargo_holds = @game.cargo_holds_for_train(@g2038_selected_train)
          cargo_holds - (@g2038_pickups || []).size
        end

        # True if holds are full and this key isn't already checked.
        def picks_full?(rem, pending, key)
          pending.size >= rem && !pending.include?(key)
        end

        def cleanup(skip: false)
          store(:g2038_selected_train, nil, skip: true)
          store(:g2038_hex_route, [], skip: true)
          store(:g2038_lock_at, nil, skip: true)
          store(:g2038_pickups, [], skip: true)
          store(:g2038_pending_picks, nil, skip: true)
          store(:g2038_explore_count, 0, skip: true)
          store(:g2038_explore_pending, nil, skip: skip)
        end
      end
    end
  end
end
