# frozen_string_literal: true

module View
  module Game
    class Issuers < Snabberb::Component
      needs :game
      needs :owner, default: nil

      def render
        bonds = @game.all_issuers.flat_map do |i|
          bonds_of_issuer = @owner.bonds_of(i)
          next unless bonds_of_issuer.any?

          render_issuer_holding(bonds_of_issuer)
        end

        table_props = {
          style: {
            padding: '0 0.5rem 0.2rem',
            grid: 'auto / 1fr auto auto',
            gap: '0 0.3rem',
          },
        }

        h('div.issuers_table', table_props, [
          h('div.bold', 'Bonds'),
          h('div.bold', 'Value'),
          h('div.bold.right', 'Income'),
          *bonds,
        ])
      end

      def render_issuer_holding(bonds)
        issuer = bonds.first.issuer
        count = bonds.size
        [h(:div, "#{count} #{issuer.name}"),
         h('div.padded_number', formatted_value(issuer.value, count)),
         h('div.padded_number', formatted_value(issuer.revenue, count))]
      end

      def formatted_value(value, count)
        @game.format_currency(value * count)
      end
    end
  end
end
