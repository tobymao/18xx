# frozen_string_literal: true

require 'view/game/corporation'

module View
  module Game
    class Corporations < Snabberb::Component
      needs :game
      needs :user, default: nil

      def render
        player_owned, bank_owned = (@game.corporations + @game.minors).partition(&:owner)

        children = player_owned
          .group_by(&:owner)
          .sort_by { |owner, _| owner.name == @user&.dig(:name) ? '' : owner.name }
          .map { |owner, corporations| render_corporations(owner, corporations) }

        children << render_corporations(@game.bank, bank_owned)

        h('div#corp-tab', children)
      end

      def render_corporations(owner, corporations)
        h('div.corp__row', { style: { 'margin-bottom': '0.5rem' } }, [
          h('div.owner', { style: { 'border-bottom': '1px solid gainsboro' } }, owner.name),
          *corporations.sort_by(&:name).map { |c| h(Corporation, corporation: c) },
        ])
      end
    end
  end
end
