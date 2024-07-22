# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    module Round
      class Bid < Snabberb::Component
        include Actionable
        needs :entity
        needs :biddable

        def render
          return '' unless (step = @game.round.step_for(@entity, 'bid'))

          children = []
          children << h(:div, [step.bid_description]) if step.respond_to?(:bid_description) && step.bid_description

          min_increment = step.min_increment

          min_bid = step.min_bid(@biddable)
          max_bid = step.max_bid(@entity, @biddable)
          price_input = h(:input, style: { marginRight: '1rem' }, props: {
                            value: min_bid,
                            step: min_increment,
                            min: min_bid,
                            max: max_bid,
                            type: 'number',
                            size: [@entity.cash.to_s.size, max_bid.to_s.size].max,
                          })

          place_bid = lambda do
            process_action(Engine::Action::Bid.new(
              @entity,
              corporation: @biddable.corporation? ? @biddable : nil,
              company: @biddable.company? ? @biddable : nil,
              price: Native(price_input)[:elm][:value].to_i,
            ))
          end

          bid_button = h(:button, { on: { click: place_bid } }, 'Place Bid')
          children << h(:div, [price_input, bid_button])

          h('div.center', children)
        end
      end
    end
  end
end
