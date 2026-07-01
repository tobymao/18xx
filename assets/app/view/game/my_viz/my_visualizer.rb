# frozen_string_literal: true

module View
  module Game
    class MyVisualizer < Snabberb::Component
      needs :game
      needs :tile_selector, default: nil

      # We initialize local component states for the sliding layout split percentage
      needs :viz_split_pct, default: 50, store: true
      needs :viz_is_dragging, default: false, store: true

      def render
        split_pct = @viz_split_pct
        
        # Main Flexible Container Workspace
        h(:div, {
          style: {
            display: 'flex',
            flexDirection: 'row',
            width: '100%',
            height: '80vh',
            userSelect: @viz_is_dragging ? 'none' : 'auto',
            position: 'relative'
          },
          on: {
            mousemove: ->(e) { handle_mousemove(e) },
            mouseup: ->(_e) { handle_mouseup }
          }
        }, [
          # Left Panel: Game Map
          h(:div, {
            style: {
              width: "#{split_pct}%",
              overflow: 'auto',
              border: '1px solid #ccc',
              padding: '0.5rem'
            }
          }, [
            h(View::Game::Map, game: @game, opacity: 1.0, tile_selector: @tile_selector)
          ]),

          # Draggable Center Splitter Bar
          h(:div, {
            style: {
              width: '10px',
              cursor: 'col-resize',
              backgroundColor: @viz_is_dragging ? '#333' : '#aaa',
              margin: '0 4px',
              transition: 'background-color 0.1s'
            },
            on: {
              mousedown: ->(e) { handle_mousedown(e) }
            }
          }),

          # Right Column: Split Vertically (Spreadsheet top, Market bottom)
          # --- START FIX ---
          h(:div, {
            style: {
              width: "calc(100% - #{split_pct}% - 18px)",
              display: 'flex',
              flexDirection: 'column',
              height: '100%',
              gap: '0.5rem'
            }
          }, [
            # Top Right: Spreadsheet Ledger
            h(:div, {
              style: {
                flex: '1 1 50%',
                overflow: 'auto',
                border: '1px solid #ccc',
                padding: '0.5rem'
              }
            }, [
              h(View::Game::Spreadsheet, game: @game)
            ]),

            # Bottom Right: Stock Market
            h(:div, {
              style: {
                flex: '1 1 50%',
                overflow: 'auto',
                border: '1px solid #ccc',
                padding: '0.5rem'
              }
            }, [
              h(View::Game::StockMarket, game: @game, explain_colors: false)
            ])
          ])
        ])
      end

      private

      def handle_mousedown(e)
        event = Native(e)
        event.preventDefault
        store(:viz_is_dragging, true, skip: true)
      end

      def handle_mousemove(e)
        return unless @viz_is_dragging

        native_event = Native(e)
        # Calculate cursor's relative horizontal position over total window width
        window_width = `window.innerWidth`.to_f
        client_x = native_event['clientX'].to_f
        
        # Convert to strict percentages clamped safely between 15% and 85%
        new_pct = ((client_x / window_width) * 100).round
        new_pct = [15, [new_pct, 85].min].max

        store(:viz_split_pct, new_pct)
      end

      def handle_mouseup
        return unless @viz_is_dragging
        store(:viz_is_dragging, false)
      end
    end
  end
end