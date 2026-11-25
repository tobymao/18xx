# frozen_string_literal: true

require_relative 'actionable'

module View
  module Game
    class BuyCompanyFromOtherPlayer < Snabberb::Component
      include Actionable

      needs :companies

      def render
        props = {
          style: {
            grid: '1fr / 5rem 4rem',
            alignItems: 'center',
            margin: '1rem 0 1.5rem 0',
          },
        }

        step = @game.round.active_step
        player = @game.current_entity
        ranges = @companies.map { |company| step.price_range(player, company) }
        min = ranges.map(&:first).min
        max = ranges.map(&:last).max
        input = h(:input, style: { marginBottom: '0.5rem', marginRight: '1rem' }, props: {
                    value: min,
                    type: 'number',
                    min: min,
                    max: max,
                    size: max.to_s.size + 2,
                  })
        children = [input]
        @companies.each do |company|
          children << render_company_buy(input, company)
        end
        h(:div, props, children)
      end

      private

      def render_company_buy(input, company)
        buy_company = lambda do
          price = Native(input).elm.value.to_i
          process_action(Engine::Action::BuyCompany.new(
            @game.current_entity,
            company: company,
            price: price,
          ))
        end

        buy = -> { check_consent(@game.current_entity, company.owner, buy_company) }

        owner_name = company.owner.nil? ? 'the market' : company.owner.name
        h(:button, { on: { click: buy } }, "Buy #{company.id} from #{owner_name}")
      end
    end
  end
end
