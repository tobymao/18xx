# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class MyVisualizer < Snabberb::Component
      needs :game
      needs :game_data, store: true
      needs :tile_selector, default: nil
      needs :routes, store: true, default: []
      needs :tick_trigger, store: true, default: 0
      include Actionable

      def tick_clock
        store(:tick_trigger, Time.now.to_i)
        update! if respond_to?(:update!)
      end

      def active_entity
        @game.round.active_step&.current_entity
      end

      def active_player
        entity = active_entity
        return nil unless entity

        if entity.player?
          entity
        elsif entity.respond_to?(:player) && entity.player
          entity.player
        else
          entity.owner
        end
      end

      def render
        # Capture the Snabberb component instance to survive the JS boundary
        comp = self
        h(:div, {
            hook: {
              insert: lambda {
                        `document.body.style.overflow = 'hidden'`
                        `document.body.style.margin = '0'`
                        `document.body.style.padding = '0'`
                        `document.body.style.backgroundColor = '#ffffff'`
                        `document.getElementById('app') && Object.assign(document.getElementById('app').style, { overflow: 'hidden', padding: '0', margin: '0', maxWidth: '100vw', width: '100vw', height: '100vh', backgroundColor: '#ffffff' })`
                        `document.getElementById('game') && Object.assign(document.getElementById('game').style, { overflow: 'hidden', width: '100vw', height: '100vh', maxWidth: '100vw', maxHeight: '100vh' })`

                        # Use Opal's interpolation to bridge the Ruby instance into JS
                        @clock_ticker = `setInterval(function() { #{comp}.$tick_clock(); }, 1000)`
                      },
              destroy: lambda {
                         `clearInterval(#{@clock_ticker})`
                         `document.body.style.overflow = ''`
                         `document.body.style.margin = ''`
                         `document.body.style.padding = ''`
                         `document.body.style.backgroundColor = ''`
                         `document.getElementById('app') && Object.assign(document.getElementById('app').style, { overflow: '', padding: '', margin: '', maxWidth: '', width: '', height: '', backgroundColor: '' })`
                         `document.getElementById('game') && Object.assign(document.getElementById('game').style, { overflow: '', width: '', height: '', maxWidth: '', maxHeight: '' })`
                       },
            },
            attrs: { id: 'viz-master-frame' },
            style: {
              display: 'flex',
              flexDirection: 'row',
              width: '100vw',
              height: '100vh',
              maxHeight: '100vh',
              boxSizing: 'border-box',
              position: 'relative',
              gap: '0.75rem',
              overflow: 'hidden',
              padding: '0.5rem',
              backgroundColor: '#ffffff',
            },
          }, [
          # Column 1 (Far Left): Command Column Tracker (10% width)
          h(:div, { style: { width: '10%', height: '100%', border: '1px solid #ccc', borderRadius: '4px', backgroundColor: '#fff', overflow: 'hidden' } }, [
            h(View::Game::CommandColumn, game: @game),
          ]),

          # Column 2 (Middle): Entity Order (Top) & Map Canvas (Bottom) (41% width)
          h(:div, { style: { width: '41%', height: '100%', display: 'flex', flexDirection: 'column', gap: '0.5rem', overflow: 'hidden' } }, [
            # Narrow Strip: Entity Order Section
            h(:div, { style: { flex: '0 0 auto', border: '1px solid #ccc', borderRadius: '4px', backgroundColor: '#fff', padding: '0.25rem', overflow: 'auto' } }, [
              h(View::Game::MyEntityOrder, round: @game.round),
            ]),

            # Map Panel Box
            h(:div, { style: { flex: '1 1 auto', border: '1px solid #ccc', borderRadius: '4px', backgroundColor: '#fff', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', overflow: 'hidden' } }, [
              h(:div, {
                  style: {
                    width: '100%',
                    height: '100%',
                    display: 'flex',
                    justifyContent: 'center',
                    alignItems: 'center',
                    overflow: 'hidden',
                    '& svg': {
                      width: '100% !important',
                      height: '100% !important',
                      maxWidth: '100%',
                      maxHeight: '100%',
                      objectFit: 'contain',
                    },
                    '& text': { fontSize: '0.65em !important', letterSpacing: 'normal !important' },
                    '& .tile__text': { fontSize: '0.75em !important' },
                    '& text.number': { fontSize: '0.55em !important' },
                  },
                }, [
                h(View::Game::Map, game: @game, opacity: 1.0, tile_selector: @tile_selector, minimal: true),
              ]),
            ]),
          ]),

          # Column 3 (Far Right): Status Stack (49% width)
          h(:div, { style: { width: '49%', display: 'flex', flexDirection: 'column', height: '100%', maxHeight: '100%', gap: '0.5rem', overflow: 'hidden' } }, [
            # Spreadsheet Ledger Component
            h(:div, {
                style: {
                  flex: '1 1 62%',
                  overflow: 'auto',
                  border: '1px solid #ccc',
                  padding: '0.4rem',
                  borderRadius: '4px',
                  backgroundColor: '#fff',
                  display: 'flex',
                  flexDirection: 'column',
                  '& div': { overflow: 'auto !important' },
                  '& table': {
                    width: '100% !important',
                    tableLayout: 'fixed',
                    borderCollapse: 'collapse',
                    fontSize: '0.7rem !important',
                  },
                  '& th': {
                    padding: '2px !important',
                    fontWeight: 'bold',
                    borderBottom: '2px solid #ccc',
                    textOverflow: 'ellipsis',
                    overflow: 'hidden',
                    whiteSpace: 'nowrap',
                  },
                  '& td': {
                    padding: '2px !important',
                    whiteSpace: 'normal',
                    wordBreak: 'break-word',
                    borderBottom: '1px solid #eee',
                  },
                },
              }, [
              # Hooking into your custom implementation sandbox
              h(View::Game::GameStatus, game: @game),
            ]),

            h(:div, {
                style: {
                  flex: '0 0 8%',
                  minHeight: '3.5rem',
                  border: '1px solid #ccc',
                  borderRadius: '4px',
                  backgroundColor: '#fff',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'flex-start',
                  padding: '0 0.75rem',
                  boxSizing: 'border-box',
                },
              }, begin
                active_p = active_player
                step = @game.round.active_step
                current_entity = step&.current_entity
                actions = current_entity ? step.actions(current_entity) : []

                undo_handler = -> { process_action(Engine::Action::Undo.new(active_p)) if active_p }
                redo_handler = -> { process_action(Engine::Action::Redo.new(active_p)) if active_p }

                default_btn_text = 'Pass'
                default_handler = lambda {
                  process_action(Engine::Action::Pass.new(current_entity)) if current_entity && actions.include?('pass')
                }

                if @game.round.stock?
                  default_btn_text = 'Pass'
                elsif actions.include?('lay_tile')
                  default_btn_text = 'Skip Build'
                elsif actions.include?('place_token')
                  default_btn_text = 'Skip Token'
                elsif actions.include?('run_routes')
                  default_btn_text = 'Submit Revenue'
                  default_handler = lambda {
                    active_routes = @routes.select { |r| r.chains.any? }
                    base_revenue = active_routes.any? ? active_routes.sum(&:revenue) : 0
                    storage_key = "rev_override_#{current_entity&.id}"
                    current_revenue = Lib::Storage[storage_key] ? Lib::Storage[storage_key].to_i : base_revenue
                    process_action(Engine::Action::RunRoutes.new(
                      current_entity,
                      routes: active_routes,
                      extra_revenue: @game.extra_revenue(current_entity, active_routes) + (current_revenue - base_revenue),
                      subsidy: @game.routes_subsidy(active_routes)
                    ))
                  }
                elsif actions.include?('dividend')
                  default_btn_text = 'Pay Out'
                  default_handler = lambda {
                    if current_entity && actions.include?('dividend')
                      process_action(Engine::Action::Dividend.new(current_entity, kind: 'payout'))
                    end
                  }
                elsif actions.include?('buy_train')
                  default_btn_text = 'Finished Buying'
                end
                button_style = {
                  padding: '0.5rem 1.5rem',
                  fontSize: '1.1rem',
                  fontWeight: 'bold',
                  marginRight: '0.75rem',
                  cursor: 'pointer',
                  borderRadius: '4px',
                  border: '1px solid #999',
                  verticalAlign: 'middle',
                }

                btns = [
                   h(:button,
                     { attrs: { id: 'undo' }, style: button_style.merge(backgroundColor: '#e0e0e0', color: '#000000'), on: { click: undo_handler } }, 'Undo'),
                   h(:button,
                     { attrs: { id: 'redo' }, style: button_style.merge(backgroundColor: '#e0e0e0', color: '#000000'), on: { click: redo_handler } }, 'Redo'),
                   h(:button,
                     { attrs: { id: 'pass' }, style: button_style.merge(backgroundColor: '#007bff', borderColor: '#0056b3', color: '#ffffff'), on: { click: default_handler } }, default_btn_text),
                 ]

                if active_p
                  # Extract remaining baseline time from server payload
                  times_hash = @game_data&.dig('thinking_times') || @game_data&.dig(:thinking_times) || {}

                  # Map the Engine Player name to the database User ID to match backend thinking_times keys
                  game_players = @game_data&.dig('players') || @game_data&.dig(:players) || []
                  user_match = game_players.find { |u| u['name'] == active_p.name || u[:name] == active_p.name }
                  user_id = user_match ? (user_match['id'] || user_match[:id]) : active_p.id

                  base_time = times_hash[user_id.to_s] || times_hash[user_id.to_i] || 300

                  # Compare current local time directly to the last action milestone

                  last_act = @game_data&.dig('last_action_at') || @game_data&.dig(:last_action_at) ||
                             @game_data&.dig('updated_at') || @game_data&.dig(:updated_at) ||
                             Time.now.to_i

                  # Guard: Convert millisecond epochs safely to seconds if detected
                  last_act = last_act.to_i / 1000 if last_act.to_i > 5_000_000_000

                  # Read and explicitly anchor the reactive trigger to force the Snabberb VDOM repaint engine
                  _tick = @tick_trigger

                  # Calculate true decay purely on the frontend base checkpoint
                  current_frontend_time = Time.now.to_i
                  elapsed_seconds = current_frontend_time - last_act.to_i
                  time_val = (base_time - elapsed_seconds).to_i

                  abs_time = time_val.abs
                  mins = (abs_time / 60).to_i
                  secs = (abs_time % 60).to_i
                  formatted_time = "#{time_val < 0 ? '-' : ''}#{mins}:#{secs < 10 ? '0' : ''}#{secs}"

                  `console.log("--- CHESS TIMER DEBUG LOG ---")`
                  `console.log("Active Player:", #{active_p&.name || 'nil'})`
                  %x(console.log("Full Game Data Hash:", #{begin
                    JSON.generate(@game_data.to_h)
                  rescue StandardError
                    '{}'
                  end}))
                  `console.log("Extracted Base Time:", #{base_time})`
                  `console.log("Raw Last Action At Checkpoint:", #{last_act})`
                  `console.log("Current Front-End System Epoch:", #{current_frontend_time})`
                  `console.log("Computed Elapsed Seconds:", #{elapsed_seconds})`
                  `console.log("Computed Final Time Value:", #{time_val})`
                  `console.log("Reactive Tick Trigger State:", #{_tick})`

                  btns << h(:span, {
                              style: {
                                marginLeft: 'auto',
                                fontSize: '1.8rem',
                                fontWeight: 'bold',
                                color: time_val < 0 ? '#ff0000' : '#000000',
                              },
                            }, "#{active_p.name}: #{formatted_time}")
                end

                btns
              end),

            # Stock Market Component
            h(:div, { style: { flex: '1 1 30%', overflow: 'hidden', border: '1px solid #ccc', padding: '0.5rem', borderRadius: '4px', backgroundColor: '#fff', display: 'flex', justifyContent: 'flex-start', alignItems: 'center', flexDirection: 'column' } }, [
                h(:div, { style: { width: '100%', height: '100%', display: 'flex', justifyContent: 'center', alignItems: 'flex-start', transform: 'scale(0.85)', transformOrigin: 'center top', marginTop: '-5px' } }, [
                  h(View::Game::SimpleStockMarket, game: @game),
                ]),
              ]),
          ]),
        ])
      end
    end
  end
end
