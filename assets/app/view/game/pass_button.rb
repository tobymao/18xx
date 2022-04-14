# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class PassButton < Snabberb::Component
      include Actionable

      needs :for_player, default: nil
      needs :before_process_pass, default: -> {}, store: true

      def render
        props = {
          on: {
            click: lambda do
              @before_process_pass.call
              process_action(Engine::Action::Pass.new(@for_player || @game.pass_entity(@user)))
            end,
          },
        }

        for_text = @for_player ? " (#{@for_player.name})" : ''
        h(:button, props, "#{@game.round.pass_description}#{for_text}")
      end
    end
  end
end
