# frozen_string_literal: true

require 'view/actionable'
require 'view/log'

module View
  class GameLog < Snabberb::Component
    include Actionable

    needs :user

    def render
      children = [
        h(Log, log: @game.log, negative_pad: true),
      ]

      @player = @game.player_by_id(@user['name']) if @user

      enter = lambda do |event|
        event = Native(event)
        code = event['keyCode']

        if code && code == 13
          message = event['target']['value']
          if message.strip != ''
            event['target']['value'] = ''
            process_action(Engine::Action::Message.new(@player, message))
          end
        end
      end

      if @player
        children << h(:div, { style: {
            'margin-top': '0.5rem',
            'display': 'flex',
            'flex-direction': 'row',
          } }, [
            h(:span, { style: {
              'font-weight': 'bold',
              'margin-top': '4px',
             } }, [@user['name'] + ':']),
            h(:input,
              style: {
                'margin-left': '0.5rem',
                'flex': '1',
              },
              on: { keyup: enter }),
          ])
      end

      props = {
        style: {
          display: 'inline-block',
          width: '100%',
          margin: '1rem 0 1rem 0',
        },
      }

      h(:div, props, children)
    end
  end
end
