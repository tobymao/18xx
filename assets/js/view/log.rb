# frozen_string_literal: true

module View
  class Log < Snabberb::Component
    needs :game, store: true

    def render
      reverse_scroll = lambda do |event|
        %x{
          var e = #{event}
          e.preventDefault()
          e.currentTarget.scrollTop -= e.deltaY
        }
      end

      props = {
        on: { wheel: reverse_scroll },
        style: {
          transform: 'scaleY(-1)',
          overflow: 'auto',
          height: '200px',
          margin: '5px 0',
          'background-color': 'lightgray',
        },
      }

      lines = @game.log.reverse.map do |line|
        h(:div, { style: { transform: 'scaleY(-1)' } }, line)
      end

      h(:div, props, lines)
    end
  end
end
