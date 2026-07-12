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
      needs :user, default: nil
      include Actionable

      def tick_clock
        store(:tick_trigger, Time.now.to_i)
        update! if respond_to?(:update!)
      end

      def active_entity
        @game.round.active_step&.current_entity
      rescue NotImplementedError, StandardError
        nil
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
        if @game.respond_to?(:finished?) && @game.finished?
          return h(:div, {
                     style: { display: 'flex', flexDirection: 'row', width: '100vw', height: '100vh', padding: '0.5rem', boxSizing: 'border-box', backgroundColor: '#ffffff', gap: '0.75rem' },
                   }, [
            # Column 1: Static Game Ended Command Column
            h(:div, { style: { width: '10%', height: '100%', border: '1px solid #ccc', borderRadius: '4px', backgroundColor: '#e2e3e5', display: 'flex', alignItems: 'center', justifyContent: 'center' } }, [
              h(:h2, { style: { color: '#dc3545', margin: '0', textAlign: 'center', fontFamily: '"Helvetica Neue", Helvetica, Arial, sans-serif' } }, 'Game Ended'),
            ]),

            # Column 2: Map
            h(:div, { style: { width: '41%', height: '100%', display: 'flex', flexDirection: 'column', gap: '0.5rem', overflow: 'hidden' } }, [
              h(:div, { style: { flex: '1 1 auto', border: '1px solid #ccc', borderRadius: '4px', display: 'flex', justifyContent: 'center', alignItems: 'center', overflow: 'hidden' } }, [
h(:div, { attrs: { class: 'scaler-content' }, style: { display: 'flex', justifyContent: 'center', alignItems: 'center' } }, [
h(View::Game::Map, game: @game, user: @user, minimal: true),
                ]),
              ]),
            ]),

            # Column 3: Final Status and Stock Market
            h(:div, { style: { width: '49%', display: 'flex', flexDirection: 'column', height: '100%', gap: '0.5rem' } }, [
              h(:div, { style: { flex: '1 1 62%', border: '1px solid #ccc', padding: '2rem', borderRadius: '4px', textAlign: 'center', fontFamily: '"Helvetica Neue", Helvetica, Arial, sans-serif' } }, [
                h(:h3, 'Final Match State'),
                h(:p, 'The 1846 game has concluded. Active turn components and ledgers are disabled.'),
              ]),
              h(:div, { style: { flex: '1 1 30%', border: '1px solid #ccc', padding: '0.5rem', borderRadius: '4px', display: 'flex', justifyContent: 'center', alignItems: 'flex-start', overflow: 'hidden' } }, [
h(:div, { attrs: { class: 'scaler-content' }, style: { width: '100%', height: '100%', display: 'flex', justifyContent: 'center', alignItems: 'flex-start', transformOrigin: 'center top' } }, [
                    h(View::Game::SimpleStockMarket, game: @game),
                ]),
              ]),
            ]),
          ])
        end

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

                        %x(window.init18xxResizers = function() {
                          var createResizer = function(resizerId, prevId, nextId, isVertical) {
                            var resizer = document.getElementById(resizerId);
                            var prev = document.getElementById(prevId);
                            var next = document.getElementById(nextId);
                            if(!resizer || !prev || !next) return;
                            var x = 0, y = 0, prevFlex = 0, nextFlex = 0;
                            var mouseDownHandler = function(e) {
                              x = e.clientX; y = e.clientY;
                              var prevRect = prev.getBoundingClientRect();
                              var nextRect = next.getBoundingClientRect();
                              prevFlex = isVertical ? prevRect.height : prevRect.width;
                              nextFlex = isVertical ? nextRect.height : nextRect.width;
                              document.addEventListener('mousemove', mouseMoveHandler);
                              document.addEventListener('mouseup', mouseUpHandler);
                              document.body.style.cursor = isVertical ? 'row-resize' : 'col-resize';
                            };
                            var mouseMoveHandler = function(e) {
                              var delta = isVertical ? (e.clientY - y) : (e.clientX - x);
                              var totalFlex = prevFlex + nextFlex;
                              var newPrevFlex = Math.max(0, prevFlex + delta);
                              var newNextFlex = Math.max(0, totalFlex - newPrevFlex);
                              prev.style.flex = '0 0 ' + newPrevFlex + 'px';
                              next.style.flex = '0 0 ' + newNextFlex + 'px';
                              if (!isVertical && nextId === 'col-3') {
                                next.style.flex = '1 1 auto';
                              }
                              prev.style.width = 'auto'; prev.style.height = 'auto';
                              next.style.width = 'auto'; next.style.height = 'auto';
                            };
                            var mouseUpHandler = function() {
                              document.removeEventListener('mousemove', mouseMoveHandler);
                              document.removeEventListener('mouseup', mouseUpHandler);
                              document.body.style.cursor = '';
                            };
                            resizer.addEventListener('mousedown', mouseDownHandler);
                          };
                          createResizer('resizer-v-1', 'col-1', 'col-2', false);
                          createResizer('resizer-v-2', 'col-2', 'col-3', false);
                          createResizer('resizer-h-3-1', 'panel-3-top', 'panel-3-bot', true);
                          createResizer('resizer-h-3-2', 'panel-3-top', 'panel-3-bot', true);


                          var fitObserver = new ResizeObserver(function(entries) {
                            for (var i = 0; i < entries.length; i++) {
                              var panel = entries[i].target;
                              var wrapper = panel.querySelector('.scaler-content');
                              if (!wrapper) continue;

                             wrapper.style.transform = 'none';
                              wrapper.style.width = 'max-content';
                              wrapper.style.height = 'max-content';

                              var cw = wrapper.scrollWidth;
                              var ch = wrapper.scrollHeight;
                              var pw = entries[i].contentRect.width - 16; // Account for panel padding
                              var ph = entries[i].contentRect.height - 16;

                              if (cw > 0 && ch > 0) {
                                var scale = Math.min(pw / cw, ph / ch);
                                wrapper.style.transform = 'scale(' + scale + ')';
                                // Lock the container dimensions to the scaled footprint to prevent layout collapse
                                panel.style.display = 'block';
                                wrapper.style.width = cw + 'px';
                                wrapper.style.height = ch + 'px';
                              }
                            }
                          });

              ['col-1', 'panel-2-bot', 'panel-3-top', 'panel-3-bot'].forEach(function(id) {
                            var el = document.getElementById(id);
                            if (el) fitObserver.observe(el);
                          });
                        };
                        setTimeout(window.init18xxResizers, 200);)
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
              overflow: 'hidden',
              padding: '0.5rem',
              backgroundColor: '#ffffff',
            },
          }, [
          # Column 1 (Far Left): Command Column Tracker
          h(:div, { attrs: { id: 'col-1' }, style: { flex: '0 0 10%', height: '100%', border: '1px solid #ccc', borderRadius: '4px', backgroundColor: '#fff', overflow: 'hidden' } }, [
            h(View::Game::CommandColumn, game: @game),
          ]),

          # Vertical Resizer 1 (replaces 0.75rem gap)
          h(:div, { attrs: { id: 'resizer-v-1' }, style: { flex: '0 0 0.75rem', cursor: 'col-resize', zIndex: 10 } }),

          # Column 2 (Middle): Entity Order (Top) & Map Canvas (Bottom)
          h(:div, { attrs: { id: 'col-2' }, style: { flex: '0 0 41%', height: '100%', display: 'flex', flexDirection: 'column', overflow: 'hidden' } }, [
            # Narrow Strip: Entity Order Section
            h(:div, { attrs: { id: 'panel-2-top' }, style: { flex: '0 0 auto', minHeight: '3rem', border: '1px solid #ccc', borderRadius: '4px', backgroundColor: '#fff', padding: '0.25rem', overflow: 'auto' } }, [
                if @game.respond_to?(:finished?) && @game.finished?
                  h(View::Game::MyEntityOrder, round: nil)
                else
                  h(View::Game::MyEntityOrder, round: @game.round)
                end,
              ]),

            # Horizontal Resizer 2 (replaces 0.5rem gap)
            h(:div, { attrs: { id: 'resizer-h-2' }, style: { flex: '0 0 0.5rem', cursor: 'row-resize', zIndex: 10 } }),

            # Map Panel Box
            h(:div, { attrs: { id: 'panel-2-bot' }, style: { flex: '1 1 auto', border: '1px solid #ccc', borderRadius: '4px', backgroundColor: '#fff', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', overflow: 'hidden' } }, [
                                         h(:div, {
                                             attrs: { class: 'scaler-content' },
                                             style: {
                                               display: 'flex',
                                               justifyContent: 'center',
                                               alignItems: 'center',
                                               '& text': { fontSize: '0.65em !important', letterSpacing: 'normal !important' },
                                               '& .tile__text': { fontSize: '0.75em !important' },
                                               '& text.number': { fontSize: '0.55em !important' },
                                             },
                                           }, [
h(View::Game::Map, game: @game, user: @user, minimal: true),
]),
                        ]),
          ]),

          # Column 3 (Far Right): Status Stack (49% width)
          # Vertical Resizer 2 (replaces 0.75rem gap)
          h(:div, { attrs: { id: 'resizer-v-2' }, style: { flex: '0 0 0.75rem', cursor: 'col-resize', zIndex: 10 } }),

          # Column 3 (Far Right): Status Stack
          h(:div, { attrs: { id: 'col-3' }, style: { flex: '1 1 auto', display: 'flex', flexDirection: 'column', height: '100%', maxHeight: '100%', overflow: 'hidden' } }, [
            # Spreadsheet Ledger Component
            h(:div, {
                attrs: { id: 'panel-3-top' },
                style: {
                  flex: '0 0 62%',
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
                    fontSize: '0.85rem',
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
                    whiteSpace: 'nowrap',
                    textOverflow: 'ellipsis',
                    borderBottom: '1px solid #eee',
                  },
                },
              }, [
               h(:div, { attrs: { class: 'scaler-content' }, style: { display: 'flex', flexDirection: 'column', width: '100%' } }, [
                  if @game.respond_to?(:finished?) && @game.finished?
                    h(:div, { style: { padding: '1rem', fontFamily: '"Helvetica Neue", Helvetica, Arial, sans-serif', textAlign: 'center' } }, [
                      h(:h3, { style: { color: '#dc3545', margin: '0 0 0.5rem 0' } }, 'Match Verification Complete'),
                      h(:p, { style: { fontSize: '0.85rem', color: '#555', margin: '0' } },
                        'The 1846 game engine successfully processed all historical match movements deterministically. Active turn ledger is disabled for completed states.'),
                    ])
                  else
                    h(View::Game::GameStatus, game: @game)
                  end,
                ]),
                ]),

            # Horizontal Resizer 3-1
            h(:div, { attrs: { id: 'resizer-h-3-1' }, style: { flex: '0 0 0.5rem', cursor: 'row-resize', zIndex: 10 } }),

            h(:div, {
                attrs: { id: 'panel-3-mid' },
                style: {
                  flex: '0 0 auto',
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
                step = begin
                  @game.round.active_step
                rescue NotImplementedError, Exception
                  nil
                end
                current_entity = step&.current_entity
                actions = if current_entity && step.respond_to?(:actions)
                            begin
                              step.actions(current_entity)
                            rescue StandardError
                              []
                            end
                          else
                            []
                          end
                undo_handler = -> { process_action(Engine::Action::Undo.new(active_p)) if active_p }
                redo_handler = -> { process_action(Engine::Action::Redo.new(active_p)) if active_p }

                default_btn_text = 'Pass'
                default_handler = lambda {
                  process_action(Engine::Action::Pass.new(current_entity)) if current_entity && actions.include?('pass')
                }

                if @game.round.respond_to?(:stock?) && @game.round.stock?
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
                      extra_revenue: @game.extra_revenue(current_entity,
                                                         active_routes) + (current_revenue - base_revenue),
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

                # Check for endgame state immediately to avoid executing any un-implemented engine action queries
                if (@game.respond_to?(:finished?) && @game.finished?) || begin @game.round.active_step
                                                                               false
                rescue NotImplementedError, Exception
                  true
                end
                  [
                    h(:button,
                      { style: button_style.merge(backgroundColor: '#e0e0e0', color: '#a0a0a0', cursor: 'not-allowed'), attrs: { disabled: true } }, 'Undo'),
                    h(:button,
                      { style: button_style.merge(backgroundColor: '#e0e0e0', color: '#a0a0a0', cursor: 'not-allowed'), attrs: { disabled: true } }, 'Redo'),
                    h(:button,
                      { style: button_style.merge(backgroundColor: '#e0e0e0', color: '#a0a0a0', cursor: 'not-allowed'), attrs: { disabled: true } }, 'Match Complete'),
                  ]
                else
                  active_p = active_player
                  step = begin
                    @game.round.active_step
                  rescue StandardError
                    nil
                  end
                  current_entity = step&.current_entity
                  actions = if current_entity && step.respond_to?(:actions)
                              begin
                                step.actions(current_entity)
                              rescue StandardError
                                []
                              end
                            else
                              []
                            end

                  undo_handler = -> { process_action(Engine::Action::Undo.new(active_p)) if active_p }
                  redo_handler = -> { process_action(Engine::Action::Redo.new(active_p)) if active_p }

                  default_btn_text = 'Pass'
                  default_handler = lambda {
                    process_action(Engine::Action::Pass.new(current_entity)) if current_entity && actions.include?('pass')
                  }

                  if @game.round.respond_to?(:stock?) && @game.round.stock?
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

                  btns = [
                     h(:button,
                       { attrs: { id: 'undo' }, style: button_style.merge(backgroundColor: '#e0e0e0', color: '#000000'), on: { click: undo_handler } }, 'Undo'),
                     h(:button,
                       { attrs: { id: 'redo' }, style: button_style.merge(backgroundColor: '#e0e0e0', color: '#000000'), on: { click: redo_handler } }, 'Redo'),
                     h(:button,
                       { attrs: { id: 'pass' }, style: button_style.merge(backgroundColor: '#007bff', borderColor: '#0056b3', color: '#ffffff'), on: { click: default_handler } }, default_btn_text),
                   ]

                  if active_p && active_p.respond_to?(:thinking_time)
                    base_bank_seconds = active_p.thinking_time.to_i
                    base_bank_seconds = 300 if base_bank_seconds == 0
                    last_update_epoch = @game_data['updated_at'] || @game_data[:updated_at]
                    turn_start_seconds = last_update_epoch ? last_update_epoch.to_i : Time.now.to_i
                    elapsed_seconds = Time.now.to_i - turn_start_seconds
                    live_remaining_time = base_bank_seconds - elapsed_seconds
                    abs_time = live_remaining_time.abs
                    mins = (abs_time / 60).to_i
                    secs = (abs_time % 60).to_i
                    formatted_time = "#{live_remaining_time < 0 ? '-' : ''}#{mins}:#{secs < 10 ? '0' : ''}#{secs}"

                    btns << h(:span, { style: { marginLeft: 'auto', fontSize: '1.8rem', fontWeight: 'bold', color: live_remaining_time < 0 ? '#ff0000' : '#000000' } }, "#{active_p.name}: #{formatted_time}")
                  end

                  btns
                end
              end),
            # Horizontal Resizer 3-2
            h(:div, { attrs: { id: 'resizer-h-3-2' }, style: { flex: '0 0 0.5rem', cursor: 'row-resize', zIndex: 10 } }),

            # Stock Market Component
            h(:div, { attrs: { id: 'panel-3-bot' }, style: { flex: '1 1 auto', overflow: 'hidden', border: '1px solid #ccc', padding: '0.5rem', borderRadius: '4px', backgroundColor: '#fff', boxSizing: 'border-box', position: 'relative' } }, [
                h(:div, {
                    attrs: { class: 'scaler-content' },
                    style: {
                      transformOrigin: 'top left',
                      margin: '0 auto',
                      padding: '0',
                    },
                  }, [
                                h(View::Game::SimpleStockMarket, game: @game),
                  ]),
                ]),
          ]),
        ])
      end
    end
  end
end
