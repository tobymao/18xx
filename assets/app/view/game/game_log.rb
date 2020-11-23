# frozen_string_literal: true

require 'view/game/actionable'
require 'view/log'

module View
  module Game
    class GameLog < Snabberb::Component
      include Actionable

      needs :user

      def render
        children = [
          h(Log, log: @game.log, negative_pad: true),
        ]

        @player = @game.player_by_id(@user['id']) if @user

        enter = lambda do |event|
          event = Native(event)
          code = event['keyCode']

          if code && code == 13
            message = event['target']['value']
            if message.strip != ''
              event['target']['value'] = ''
              sender = @player || Engine::Player.new(@game_data['user']['id'], @game_data['user']['name'])
              process_action(Engine::Action::Message.new(sender, message: message))
            end
          end
        end

        if participant?
          children << h(:div, { style: {
            margin: '1vmin 0',
            display: 'flex',
            flexDirection: 'row',
          } }, [
            h(:span, { style: {
              fontWeight: 'bold',
              margin: 'auto 0',
            } }, [@user['name'] + ':']),
            h(:input,
              style: {
              marginLeft: '0.5rem',
              flex: '1',
            },
              on: { keyup: enter }),
            ])
        end

        props = {
          style: {
            display: 'inline-block',
            width: '100%',
          },
        }

        h(:div, props, children)
      end
    end
  end
end
