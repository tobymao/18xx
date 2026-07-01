# frozen_string_literal: true

module View
  module Game
    class MyVisualizer < Snabberb::Component
      needs :game
      needs :tile_selector, default: nil

      def render
        # LOCKED: Main Workspace configuration
        h(:div, {
          hook: {
            insert: lambda {
              `document.body.style.overflow = 'hidden'`
              `document.getElementById('app').style.overflow = 'hidden'`
              `document.getElementById('game').style.overflow = 'hidden'`
              
              `window.scaleTournamentDashboard = function() {
                var baseHeight = 900;
                var baseWidth = 1600;
                var currentHeight = window.innerHeight;
                var currentWidth = window.innerWidth;
                
                var scaleFactor = Math.min(currentWidth / baseWidth, currentHeight / baseHeight);
                if (scaleFactor < 0.3) scaleFactor = 0.3;
                
                var container = document.getElementById('viz-master-frame');
                if (container) {
                  container.style.transform = 'scale(' + scaleFactor + ')';
                }
              }`
              `window.addEventListener('resize', window.scaleTournamentDashboard)`
              `window.scaleTournamentDashboard()`
            },
            destroy: lambda {
              `document.body.style.overflow = 'auto'`
              `document.getElementById('app').style.overflow = 'auto'`
              `document.getElementById('game').style.overflow = 'auto'`
              `window.removeEventListener('resize', window.scaleTournamentDashboard)`
            }
          },
          attrs: {
            id: 'viz-master-frame'
          },
          style: {
            display: 'flex',
            flexDirection: 'row',
            width: '1600px',
            height: '900px', 
            maxHeight: '900px',
            position: 'relative',
            gap: '0.75rem',
            overflow: 'hidden',
            transformOrigin: 'top left'
          }
      }, [
          # Column 1 (Far Left): Command Column Tracker (10% width)
          h(:div, {
            style: {
              width: '10%',
              height: '100%',
              border: '1px solid #ccc',
              borderRadius: '4px',
              backgroundColor: '#fff',
              overflow: 'auto'
            }
          }, [
            # Replace the standalone EntityOrder with our new full-height master component
            h(View::Game::CommandColumn, game: @game)
          ]),

          # Column 2 (Middle): Map Canvas (40% width)
          h(:div, {
            style: {
              width: '40%',
              height: '100%',
              border: '1px solid #ccc',
              borderRadius: '4px',
              backgroundColor: '#fff',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'center',
              alignItems: 'center',
              overflow: 'hidden'
            }
          }, [
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
                  objectFit: 'contain'
                },
                '& text': {
                  fontSize: '0.65em !important',   
                  letterSpacing: 'normal !important'
                },
                '& .tile__text': {
                  fontSize: '0.75em !important'    
                },
                '& text.number': {
                  fontSize: '0.55em !important'    
                }
              }
            }, [
              h(View::Game::Map, game: @game, opacity: 1.0, tile_selector: @tile_selector, minimal: true)
            ])
          ]),

          # Column 3 (Far Right): Status Stack (50% width)
          h(:div, {
            style: {
              width: '50%',
              display: 'flex',
              flexDirection: 'column',
              height: '100%',
              maxHeight: '100%',
              gap: '0.5rem',
              overflow: 'hidden'
            }
          }, [
            # Top Right: Spreadsheet Ledger expanded to 60% vertical space
            h(:div, {
              style: {
                flex: '1 1 60%',
                overflow: 'auto',
                border: '1px solid #ccc',
                padding: '0.5rem',
                borderRadius: '4px',
                backgroundColor: '#fff'
              }
            }, [
              h(View::Game::Spreadsheet, game: @game)
            ]),

            # Bottom Right: Stock Market Grid restricted to 40% vertical space and scaled down
            h(:div, {
              style: {
                flex: '1 1 40%',
                overflow: 'hidden', 
                border: '1px solid #ccc',
                padding: '0.5rem',
                borderRadius: '4px',
                backgroundColor: '#fff',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center'
              }
            }, [
              h(:div, {
                style: {
                  width: '100%',
                  height: '100%',
                  display: 'flex',
                  justifyContent: 'center',
                  alignItems: 'center',
                  transform: 'scale(0.85)', # Shrinks the market matrix down by 15% inside its container
                  transformOrigin: 'center center'
                }
              }, [
                h(View::Game::StockMarket, game: @game, explain_colors: false)
              ])
            ])
            # --- END FIX ---
          ])
        ])
      end
    end
  end
end