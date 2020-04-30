# frozen_string_literal: true

require 'view/actionable'
require 'view/log'

module View
  class GameLog < Snabberb::Component
    include Actionable

    needs :user

    def render
      children = [
        h(Log, log: @game.log),
      ]

      @player = @game.player_by_id(@user['name']) if @user

      enter = lambda do |event|
        event = Native(event)
        code = event['keyCode']

        if code && code == 13
          message = event['target']['value']
          event['target']['value'] = ''
          process_action(Engine::Action::Message.new(@player, message))
        end
      end

      children << h(:input, style: { width: '100%' }, on: { keyup: enter }) if @player

      props = {
        style: {
          display: 'inline-block',
          width: '100%',
          margin: '1rem 0 1rem 0',
        }
      }

      h(:div, props, children)
    end
  end
end
