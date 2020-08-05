# frozen_string_literal: true

require_relative 'actionable'

module View
  module Game
    class BuyCompanyFromOtherPlayer < Snabberb::Component
      include Actionable

      def render
        props = {
          style: {
            grid: '1fr / 5rem 4rem',
            alignItems: 'center',
            margin: '1rem 0 1.5rem 0',
          },
        }

        max = @game.current_entity.cash.to_s.size
        input = h(:input, style: { marginBottom: '0.5rem', marginRight: '1rem' }, props: {
          value: 1,
          type: 'number',
          min: 1,
          max: max,
          size: max,
        })
        children = [input]
        @game.round.active_step.purchasable_companies_from_others(@game.current_entity).each do |company|
          children << render_company_buy(input, company)
        end if @game.round.active_step.can_buy_any_company?(@game.current_entity)
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
        h(:button, { on: { click: buy_company } }, "Buy #{company.id} from #{company.owner.name}")
      end
    end
  end
end
