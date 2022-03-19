# frozen_string_literal: true

require 'lib/settings'

module View
  module Game
    class Tranches < Snabberb::Component
      include Lib::Settings

      needs :game

      def render
        return nil unless @game.respond_to?(:tranches)

        title_props = {
          style: {
            padding: '0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            fontStyle: 'italic',
          },
        }
        body_props = {
          style: {
            margin: '0.3rem 0.5rem 0.4rem',
            display: 'grid',
            grid: 'auto / 1fr',
            gap: '0.5rem',
            justifyItems: 'center',
          },
        }

        trs = []
        tranches = @game.tranches || []
        current_tranch_index = @game.current_tranch_index
        current_tranch_available = @game.tranch_available?

        tranches.each_with_index do |tranch, tranch_index|
          slots = []

          tranch.each_with_index do |slot, _slot_index|
            available = (current_tranch_index == tranch_index and current_tranch_available)

            if slot.nil?
              available_props =
                {
                  style: {
                    backgroundColor: '#999999',
                    color: '#ffffff',
                    fontWeight: available ? 'bold' : 'normal',
                    fontStyle: 'italic',
                  },
                }

              slots << h('td.center', available_props, available ? 'open' : 'closed')
              next
            end

            slot_props =
              {
                style: {
                  fontWeight: 'bold',
                  backgroundColor: slot.color,
                  color: slot.text_color,
                },
              }

            slots << h('td.center', slot_props, slot.name)
          end

          trs << h(:tr, slots)
        end

        return if trs.empty?

        h('div#tranches.card', [
          h('div.title', title_props, 'Tranches'),
          h(:div, body_props, [
            h(:table, trs),
          ]),
        ])
      end
    end
  end
end
