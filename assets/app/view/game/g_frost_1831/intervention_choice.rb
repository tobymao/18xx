# frozen_string_literal: true

require 'lib/hex_choice_selector'
require 'view/game/actionable'

module View
  module Game
    module GFrost1831
      class InterventionChoice < Snabberb::Component
        include Actionable

        needs :game
        needs :tile_selector, default: nil, store: true

        def render
          children = [render_choices]
          children << h(Map, game: @game) if @game.round.stock?
          h(:div, children)
        end

        private

        def render_choices
          return h(:div, 'Click a highlighted hex on the map.') unless @tile_selector.is_a?(Lib::HexChoiceSelector)

          buttons = @tile_selector.choices.map do |choice, faction|
            h(:button, { on: { click: -> { choose(choice) } } }, faction.full_name)
          end
          h(:div, [h(:div, "Base in #{@tile_selector.hex.id}:"), h(:div, buttons)])
        end

        def choose(choice)
          store(:tile_selector, nil, skip: true)
          process_action(Engine::Action::Choose.new(@game.current_entity, choice: choice))
        end
      end
    end
  end
end
