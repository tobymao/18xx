# frozen_string_literal: true

module View
  module Game
    class ResultsOverlay < Snabberb::Component
      needs :game

      def render
        sorted_players = @game.players.sort_by do |p|
          if @game.respond_to?(:result) && @game.result
            @game.result[p] || 0
          else
            (@game.respond_to?(:player_value) ? @game.player_value(p) : p.cash)
          end
        end

        reveal_index = Lib::Storage['results_reveal_index'] || 0
        total_players = sorted_players.size
        revealed_players = sorted_players.take(reveal_index).reverse

        children = []
        children << h(:h2, { style: { textAlign: 'center', margin: '0 0 1rem 0' } }, 'Final Results')

        revealed_players.each_with_index do |player, idx|
          place = total_players - reveal_index + idx + 1
          val = if @game.respond_to?(:result) && @game.result
                  @game.result[player] || 0
                else
                  (@game.respond_to?(:player_value) ? @game.player_value(player) : player.cash)
                end
          formatted_val = @game.format_currency(val)

          row = h(:div, {
                    style: {
                      display: 'flex',
                      justifyContent: 'space-between',
                      padding: '0.5rem',
                      borderBottom: '1px solid #ccc',
                      fontSize: '1.2rem',
                      fontWeight: place == 1 ? 'bold' : 'normal',
                    },
                  }, [
            h(:span, "#{place}. #{player.name}"),
            h(:span, formatted_val),
          ])
          children << row
        end

        if reveal_index < total_players
          place_to_reveal = total_players - reveal_index
          place_str = place_to_reveal == 1 ? 'Winner' : "#{place_to_reveal}#{ordinal_suffix(place_to_reveal)} Place"

          reveal_handler = lambda do
            Lib::Storage['results_reveal_index'] = reveal_index + 1
            update
          end

          children << h(:button, {
                          style: {
                            width: '100%',
                            padding: '1rem',
                            marginTop: '1rem',
                            fontSize: '1.2rem',
                            backgroundColor: '#007bff',
                            color: 'white',
                            border: 'none',
                            borderRadius: '4px',
                            cursor: 'pointer',
                            fontWeight: 'bold',
                          },
                          on: { click: reveal_handler },
                        }, "Reveal #{place_str}")
        else
          close_handler = lambda do
            Lib::Storage['show_results_overlay'] = false
            update
          end
          children << h(:button, {
                          style: { width: '100%', padding: '0.5rem', marginTop: '1rem', fontSize: '1rem', cursor: 'pointer' },
                          on: { click: close_handler },
                        }, 'Close')
        end

        overlay_bg = h(:div, {
                         style: {
                           position: 'fixed',
                           top: '0',
                           left: '0',
                           width: '100vw',
                           height: '100vh',
                           backgroundColor: 'rgba(0,0,0,0.5)',
                           zIndex: '9999',
                         },
                       })

        overlay_box = h(:div, {
                          style: {
                            position: 'fixed',
                            top: '50%',
                            left: '50%',
                            transform: 'translate(-50%, -50%)',
                            backgroundColor: 'white',
                            padding: '2rem',
                            borderRadius: '8px',
                            boxShadow: '0 4px 15px rgba(0,0,0,0.3)',
                            zIndex: '10000',
                            width: '80%',
                            maxWidth: '500px',
                            color: 'black',
                          },
                        }, children)

        h(:div, [overlay_bg, overlay_box])
      end

      def ordinal_suffix(number)
        return 'th' if (11..13).cover?(number % 100)

        case number % 10
        when 1 then 'st'
        when 2 then 'nd'
        when 3 then 'rd'
        else; 'th'
        end
      end
    end
  end
end
