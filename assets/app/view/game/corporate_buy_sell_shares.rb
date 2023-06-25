# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/buy_sell_shares'
require 'view/game/corporation'
require 'view/game/par'

module View
  module Game
    class CorporateBuySellShares < Snabberb::Component
      include Actionable

      needs :selected_corporation, default: nil, store: true
      needs :corporation_to_par, default: nil, store: true

      def render
        @step = @game.round.active_step
        @current_actions = @step.current_actions
        @entity ||= @game.current_entity
        children = []

        children << h('div.margined', 'Must sell stock') if @step.respond_to?(:must_sell?) && @step.must_sell?(@current_entity)

        children.concat(render_corporations)

        h('div.margined', children.compact)
      end

      def render_corporations
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }

        corporations = if @step.respond_to?(:visible_corporations)
                         @step.visible_corporations
                       else
                         @game.sorted_corporations.reject(&:closed?)
                       end

        corporations.map do |corporation|
          children = []
          input = render_input(corporation) if @game.corporation_available?(corporation)
          children << h(Corporation, corporation: corporation, interactive: input)
          children << input if input && @selected_corporation == corporation
          h(:div, props, children)
        end.compact
      end

      def render_input(corporation)
        inputs = [
          corporation.ipoed ? h(BuySellShares, corporation: corporation) : render_pre_ipo(corporation),
        ]
        inputs = inputs.compact
        h('div.margined_bottom', { style: { width: '20rem' } }, inputs) if inputs.any?
      end

      def render_pre_ipo(corporation)
        children = []

        type = @step.ipo_type(corporation)
        case type
        when :par
          children << h(Par, corporation: corporation) if @current_actions.include?('par')
        when String
          children << h(:div, type)
        end
        children << h(BuySellShares, corporation: corporation)

        children.compact!
        return h(:div, children) unless children.empty?

        nil
      end
    end
  end
end
